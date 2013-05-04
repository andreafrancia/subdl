describe 'Subtile download' do
  subject { subdl }
  let(:subdl) { Subdl.new agent, stdout, file_system }

  let(:agent)       { double 'agent' }
  let(:stdout)      { StringIO.new }
  let(:file_system) { double 'file_system' }

  specify 'download from italian-subs.net' do

    given_GET_response(
      'http://www.italiansubs.net/modules/mod_itasalivesearch/search.php?' +
      'term=Show+1x02',
      '[{"value":"Title","id":"111"},{"value":"Title","id":"222"}]')
    agent.should_receive(:login).with('username','password')
    agent.should_receive(:login).with('username','password')
    given_GET_response(
      'http://www.italiansubs.net/index.php?option=com_remository&Itemid=6'+
      '&func=fileinfo&id=111',
      '<a href="zip_location1"><img src=".../download2.gif"></a>')
    given_GET_response(
      'http://www.italiansubs.net/index.php?option=com_remository&Itemid=6'+
      '&func=fileinfo&id=222',
      '<a href="zip_location2"><img src=".../download2.gif"></a>')
    given_GET_response('zip_location1', a_zip)
    given_GET_response('zip_location2', a_zip)
    file_system.should_receive(:save_file).with(
      "Show.S01E02.avi.itasa.srt", "contents")
    file_system.should_receive(:save_file).with(
      "Show.S01E02.avi.itasa.1.srt", "contents")
    file_system.should_receive(:read_expand).with(
      "~/.itasa-credentials").and_return("username\npassword")

    subdl.main ["Show.S01E02.avi"]

    stdout.string.lines.map(&:chomp).should include(
      "Downloaded as Show.S01E02.avi.itasa.srt")
  end

  def given_GET_response url, response_body
    agent.should_receive(:get).with(url).and_return(a_page(response_body))
  end

  def a_page content
    Struct.new(:body).new(content)
  end

  def a_zip
    buf = ''
    Zip::Archive.open_buffer(buf, Zip::CREATE) do |archive|
      archive.add_buffer 'subtitle.srt', 'contents'
    end
    return buf
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
