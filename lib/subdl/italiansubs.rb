require 'mechanize'

class ItasaAgent

  def initialize
    @agent = Mechanize.new do |a|
      a.user_agent_alias = 'Mac FireFox'
    end
  end

  def get url
    @agent.get url
  end

  def login username, password
    return if logged_in?
    page_where_to_login = 'http://www.italiansubs.net'
    home_page = @agent.get page_where_to_login
    login_form = home_page.form 'login'
    login_form.username = username
    login_form.passwd = password
    @page = @agent.submit(login_form)
  end

  private

  def logged_in?
    return false unless @page
    link_that_exists_only_once_logged = @page.search(
      "//a[@href='forum/index.php?action=unreadreplies']")
    return link_that_exists_only_once_logged.first != nil
  end
end

