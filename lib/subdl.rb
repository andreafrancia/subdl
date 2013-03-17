require 'mechanize'
require 'cgi'
require 'json'
require 'zipruby'

class Crawler

  def initialize itasa
    @itasa = itasa
  end

  def download_sub_for path
    movie_file = MovieFile.new(path)
    @itasa.each_id movie_file.search_term do |id, showname|
      @itasa.download_zip id do |zip_contents|
        unpack_subtitle_to zip_contents, movie_file
      end
    end
  end

  def unpack_subtitle_to zip_contents, movie_file
    Zip::Archive.open_buffer(zip_contents) do |archive|
      archive.each do |entry|
        movie_file.add_subtitle entry.read
      end
    end
  end

end

class MovieFile
  attr_reader :episode, :season, :show
  attr_writer :fs
  def initialize filename
    @filename = filename
    text = File.basename filename
    remove_year_from text

    if m = /^(.*)\.S(\d\d)E(\d\d)/.match(text)
      @show = m[1].gsub '.', ' '
      @season = remove_leading_zeros m[2]
      @episode = remove_leading_zeros m[3]
    end
    @fs = FileSystem
  end

  def remove_year_from text
    text.gsub! /\.20\d\d/, ''
  end

  def remove_leading_zeros text
    text.gsub /^0*/, ''
  end

  def search_term
    "%s %dx%02d" % [show, season, episode]
  end

  def add_subtitle contents
    srt_filename = @filename.gsub /.mp4$/, ''
    srt_filename += ".itasa#{next_distinguisher}.srt"
    @fs.save_file srt_filename, contents
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
  def self.save_file filename, contents
    File.open filename, 'w' do |f|
      f.write contents
    end
  end
end

class Itasa
  def initialize
    @agent = Mechanize.new do |a|
      a.user_agent_alias = 'Mac FireFox'
    end
    @page = @agent.get "http://#{host}"
  end

  def login username, password
    login_form = @page.form 'login'
    login_form.username = username
    login_form.passwd = password
    @page = @agent.submit(login_form)
  end

  def logged_in?
    link_that_exists_only_once_logged = @page.search(
      "//a[@href='forum/index.php?action=unreadreplies']")
    link_that_exists_only_once_logged.first
  end

  def each_id text
    url = URI.parse "http://#{host}/modules/mod_itasalivesearch/search.php"
    url.query = "term=#{CGI.escape text}"
    response = @agent.get url
    JSON.parse(response.body).each do |episode|
      yield episode['id'], episode['value']
    end
    nil
  end

  def download_zip id
    url = "http://#{host}/index.php?option=com_remository&Itemid=6&func=fileinfo&id=#{id}"
    page = @agent.get url
    download_link = page.search("//a[img[contains(@src,'download2.gif')]]").first
    zipped_subtitle = @agent.get download_link[:href]
    yield zipped_subtitle.body
  end

  def host
    'www.italiansubs.net'
  end
end

class Credentials
  def read_to itasa
    contents = File.read(File.expand_path('~/.itasa-credentials')).lines
    username = contents.next.chomp
    password = contents.next.chomp
    itasa.login username, password
  end
end
