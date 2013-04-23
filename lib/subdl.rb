require 'mechanize'
require 'cgi'
require 'json'
require 'zipruby'
require 'nokogiri'

class Subdl
  def initialize agent, itasa_login, stdout, file_system
    itasa = Itasa.new(agent, itasa_login)
    @crawler = Crawler.new itasa, Credentials.new, file_system, stdout
  end
  def main argv
    until argv.empty? do
      @crawler.download_sub_for argv.shift
    end
  end
end

class Crawler

  def initialize itasa, credentials, file_system, stdout
    @itasa = itasa
    @credentials = credentials
    @file_system = file_system
    @stdout = stdout
  end

  def download_sub_for path
    movie_file = MovieFile.new path, @stdout
    ids = @itasa.search_subtitles(movie_file.search_term)

    ids.each do |id|
      @itasa.login *@credentials.read
      @itasa.download_zip id do |zip_contents|
        unpack_subtitle_to zip_contents, movie_file
      end
    end
  end

  def unpack_subtitle_to zip_contents, movie_file
    Zip::Archive.open_buffer(zip_contents) do |archive|
      archive.each do |entry|
        movie_file.save_subtitle entry.read, @file_system
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

  def save_subtitle contents, fs
    srt_filename = @filename.gsub /.mp4$/, ''
    srt_filename += ".itasa#{next_distinguisher}.srt"
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
end

def mechanize_agent
  Mechanize.new do |a|
    a.user_agent_alias = 'Mac FireFox'
  end
end

class ItasaLoginForm

  def login username, password, page_where_to_login, agent
    return if logged_in?
    home_page = agent.get page_where_to_login
    login_form = home_page.form 'login'
    login_form.username = username
    login_form.passwd = password
    @page = agent.submit(login_form)
  end

  private

  def logged_in?
    return false unless @page
    link_that_exists_only_once_logged = @page.search(
      "//a[@href='forum/index.php?action=unreadreplies']")
    return link_that_exists_only_once_logged.first != nil
  end


end

class Itasa
  def initialize agent, login_form
    @agent = agent
    @login_form = login_form || ItasaLoginForm.new
  end

  def login username, password
    @login_form.login username, password, "http://#{host}", @agent
  end

  def autocomplete_data_for text
    response = @agent.get search_url(text)
    response.body
  end

  def search_subtitles text
    json = autocomplete_data_for text
    return extract_ids_from_autocomplete_data json
  end

  def extract_ids_from_autocomplete_data json
    JSON.parse(json).map { |episode| episode['id'] }
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

  def host
    'www.italiansubs.net'
  end
end

class Credentials
  def parse file_contents
    lines = file_contents.lines.to_a
    username = lines[0].chomp
    password = lines[1].chomp
    [username, password]
  end
  def read
    parse File.read(File.expand_path('~/.itasa-credentials'))
  end
end
