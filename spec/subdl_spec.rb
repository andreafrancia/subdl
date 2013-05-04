describe 'Subtile download' do
  subject { subdl }
  let(:subdl) { Subdl.new itasa, stdout, file_system }

  let(:itasa)       { double 'itasa' }
  let(:stdout)      { StringIO.new }
  let(:file_system) { double 'file_system' }

  specify 'download from italian-subs.net' do

    expect_GET(
      'http://www.italiansubs.net/modules/mod_itasalivesearch/search.php?' +
      'term=Show+1x02',
      '[{"value":"Title","id":"111"},{"value":"Title","id":"222"}]')
    file_system.should_receive(:read_expand).with(
      "~/.itasa-credentials").and_return("username\npassword")
    itasa.should_receive(:login).with('username','password')
    itasa.should_receive(:login).with('username','password')
    expect_GET(
      'http://www.italiansubs.net/index.php?option=com_remository&Itemid=6'+
      '&func=fileinfo&id=111',
      '<a href="zip_location1"><img src=".../download2.gif"></a>')
    expect_GET(
      'http://www.italiansubs.net/index.php?option=com_remository&Itemid=6'+
      '&func=fileinfo&id=222',
      '<a href="zip_location2"><img src=".../download2.gif"></a>')
    expect_GET('zip_location1', a_zip)
    expect_GET('zip_location2', a_zip)
    file_system.should_receive(:save_file).with(
      "Show.S01E02.avi.itasa.srt", "contents")
    file_system.should_receive(:save_file).with(
      "Show.S01E02.avi.itasa.1.srt", "contents")

    subdl.main ["Show.S01E02.avi"]

    output_lines.should include "Downloaded as Show.S01E02.avi.itasa.srt"
  end

  describe 'when ITASA does not have subtitles' do
    before do
      given_GET(
        'http://www.italiansubs.net/modules/mod_itasalivesearch/search.php?' +
        'term=Show+1x03',
        'null')
    end

    it 'should warn the user' do

      subdl.main ["Show.S01E03.avi"]

      output_lines.should include(
        'No subtitles found on ITASA for: Show.S01E03.avi')
    end
  end

  def output_lines
    stdout.string.lines.map &:chomp
  end

  def expect_GET url, response_body
    itasa.should_receive(:get).with(url).and_return(a_page(response_body))
  end
  def given_GET url, response_body
    itasa.stub(:get).with(url).and_return(a_page(response_body))
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
