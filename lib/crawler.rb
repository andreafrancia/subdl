require 'mechanize'
require 'cgi'
require 'json'
require 'zipruby'

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

  def unpack_subtitle_to id, directory
    url = "http://#{host}/index.php?option=com_remository&Itemid=6&func=fileinfo&id=#{id}"
    page = @agent.get url
    download_link = page.search("//a[img[contains(@src,'download2.gif')]]").first
    zipped_subtitle = @agent.get download_link[:href]
    zip_contents = zipped_subtitle.body
    Zip::Archive.open_buffer(zip_contents) do |archive|
      archive.each do |entry|
        directory.save entry.name, entry.read
      end
    end
  end

  def host
    'www.italiansubs.net'
  end
end

class Credentials
  def self.read_to itasa
    contents = File.read(File.expand_path('~/.itasa-credentials')).lines
    username = contents.next.chomp
    password = contents.next.chomp
    itasa.login username, password
  end
end
