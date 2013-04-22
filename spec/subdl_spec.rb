describe Subdl do
  it 'should downlaod subtitles' do
    agent = double 'agent'
    itasa_login = double 'itasa_login'
    stdout = StringIO.new

    subdl = Subdl.new agent, itasa_login, stdout

    agent.should_receive(:get).with(
      "http://www.italiansubs.net/modules/mod_itasalivesearch/" +
      "search.php?term=Show+1x02").and_return(
        a_page '[{"value":"Title","id":"123"}]')
    itasa_login.stub(:login)
    agent.should_receive(:get).with(
      'http://www.italiansubs.net/index.php?option=com_remository' +
      '&Itemid=6&func=fileinfo&id=123').and_return(
        a_page('<a href="zip_location"><img src=".../download2.gif"></a>'))
    agent.should_receive(:get).with('zip_location').
      and_return(a_page '')

    subdl.main ["Show.S01E02.avi"]
  end

  def a_page content
    Struct.new(:body).new(content)
  end


  # User stories:
  #  - tell which page it is reading
  #  - download subtitles from Itasa
  #  - downlaod english subtitles from sub-titles.net upon request
  #  - download english subtitles because Itasa subtitles cannot be found
  #  - download english subtitles because Itasa subtitles cannot be downloaded
  #  - downlaod italian subtitles from sub-titles in order to not get Itasa
  #    count increased
  #  - ask credentials to the user
  #  - preserve original filename from zip
  #  - gui and drag and drop
  #  - support movies
  #  - should issue a warning when the file does not exists


end
