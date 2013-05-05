require 'mechanize'
require 'cgi'
require 'json'
require 'zipruby'
require 'nokogiri'

require 'subdl/subtitles_net'
require 'subdl/italiansubs'

class Subdl
  def main argv
    until argv.empty? do
      download_sub_for argv.shift
    end
  end

  def initialize itasa, subtitles_net, stdout, file_system
    @itasa = Itasa.new itasa
    @subtitles_net = subtitles_net
    @credentials = Credentials.new file_system
    @file_system = file_system
    @stdout = stdout
  end

  def download_sub_for path
    movie_file = MovieFile.new path, @stdout
    ids = @itasa.search_subtitles(movie_file.search_term)

    if ids.any? 
      ids.each do |id|
        @itasa.login *@credentials.read
        @itasa.download_zip id do |zip_contents|
          unpack_subtitle_to zip_contents, movie_file, 'itasa'
        end
      end
    else
      @stdout.puts "No subtitles found on ITASA for: #{path}"
      show    = movie_file.show
      season  = movie_file.season
      episode = movie_file.episode
      
      search_results = SearchResults.new(
        @subtitles_net.search show, season, episode)

      details_page_link = search_results.subtitles.first.href
      page = @subtitles_net.get details_page_link
      details_page = DetailsPage.new page

      zip_contents = @subtitles_net.get details_page.zip_location
      unpack_subtitle_to zip_contents, movie_file, 'subtitles-net'
    end
  end

  def unpack_subtitle_to zip_contents, movie_file, source_id
    Zip::Archive.open_buffer(zip_contents) do |archive|
      archive.each do |entry|
        movie_file.save_subtitle entry.read, @file_system, source_id
      end
    end
  end

end

class MovieFile
  attr_reader :episode, :season, :show

  def initialize filename, stdout=nil
    @filename = filename
    text = File.basename filename
    text = remove_year_from text

    if m = /^(.*)\.S(\d\d)E(\d\d)/.match(text)
      @show = m[1].gsub '.', ' '
      @season = remove_leading_zeros m[2]
      @episode = remove_leading_zeros m[3]
    end
    @stdout = stdout
  end

  def remove_year_from text
    text.gsub /\.20\d\d/, ''
  end

  def remove_leading_zeros text
    text.gsub /^0*/, ''
  end

  def search_term
    "%s %dx%02d" % [show, season, episode]
  end

  # TODO: accept filename instead of source_id
  def save_subtitle contents, fs, source_id
    srt_filename = @filename.gsub /.mp4$/, ''
    srt_filename += ".#{source_id}#{next_distinguisher}.srt"
    @stdout.puts "Downloaded as #{srt_filename}"
    fs.save_file srt_filename, contents
  end

  def next_distinguisher
    if @subs_added
      distinguisher = ".#{@subs_added}"
    else
      distinguisher = ''
    end
    @subs_added = @subs_added.to_i + 1
    return distinguisher
  end
end

class FileSystem
  def save_file filename, contents
    File.open filename, 'w' do |f|
      f.write contents
    end
  end
  def read_expand expandable_path
    File.read(File.expand_path(expandable_path))
  end
end

class Itasa
  def initialize agent
    @agent = agent
  end

  def login username, password
    @agent.login username, password
  end

  def search_subtitles text
    json = autocomplete_data_for text
    return extract_ids_from_autocomplete_data json
  end

  def download_zip id
    page = @agent.get subtitle_page_url(id)
    zipped_subtitle = @agent.get subtitle_zip_url(page.body)
    yield zipped_subtitle.body
  end

  def subtitle_zip_url page
    doc = Nokogiri::HTML(page)
    return doc.at_xpath("//a[img[contains(@src,'download2.gif')]]")[:href]
  end

  def search_url text
    url = URI.parse "http://#{host}/modules/mod_itasalivesearch/search.php"
    url.query = "term=#{CGI.escape text}"
    return url.to_s
  end

  def subtitle_page_url id
    ("http://#{host}/index.php?option=com_remository&Itemid=6&func=fileinfo" +
     "&id=#{id}")
  end

  private 

  def autocomplete_data_for text
    response = @agent.get search_url(text)
    response.body
  end

  def extract_ids_from_autocomplete_data json
    return [] if json == 'null' 
    JSON.parse(json).map { |episode| episode['id'] }
  end

  def host
    'www.italiansubs.net'
  end
end

class Credentials
  def initialize file_reader
    @file_reader = file_reader
  end
  def parse file_contents
    lines = file_contents.lines.to_a
    username = lines[0].chomp
    password = lines[1].chomp
    [username, password]
  end
  def read
    @parsed ||= parse @file_reader.read_expand('~/.itasa-credentials')
  end
end

