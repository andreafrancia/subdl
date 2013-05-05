describe 'Subtile download' do
  subject { subdl }
  let(:subdl) { Subdl.new itasa, subtitles_net, stdout, file_system }

  let(:itasa)         { double 'itasa' }
  let(:stdout)        { StringIO.new }
  let(:file_system)   { double 'file_system' }
  let(:subtitles_net) { double 'subtitles.net' }

  specify 'download from italiansubs.net' do
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
    expect_GET('zip_location1', a_zip_with('subtitles.srt', 'contents'))
    expect_GET('zip_location2', a_zip_with('subtitles.srt', 'contents'))
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

    it 'should fallback to sub-titles.net' do
      subtitles_net.should_receive(:search).with('Show', '1', '3').
        and_return(search_results_html)
      subtitles_net.should_receive(:get).with(
        '/it/ppodnapisi/podnapis/i/2403370/hart-of-dixie-2011-subtitles').
        and_return(subtitle_details_page)
      subtitles_net.should_receive(:get).with(
        '/it/ppodnapisi/download/i/2382735/k/path-to-zip').and_return(
          a_zip_with('an_srt_file.srt', 'from subtitles.net'))
      file_system.should_receive(:save_file).with(
        "Show.S01E03.avi.subtitles-net.srt", "from subtitles.net")
        
      subdl.main ["Show.S01E03.avi"]

      output_lines.should include(
        'No subtitles found on ITASA for: Show.S01E03.avi')
    end
  end

  def search_results_html
      <<-HTML
<table class="list">
  <tr class="a">
    <td>
      <a href="/it/ppodnapisi/kategorija/jezik/2">
        <img src="/images/simple/zastave/male/2.gif" title="Inglese" >
      </a>
      <a href="/it/ppodnapisi/podnapis/i/2403370/hart-of-dixie-2011-subtitles">
        Hart of Dixie <b>(2011)</b></a>
      <img src= "/images/simple/oznake/h.gif" class="slikevvrsti" title=
      "Subtitle is for high-definition video">
      <img src= "/images/simple/oznake/u.gif" class="slikevvrsti" title=
      "Unicode encoded subtitle">&nbsp;<br>
      <span class="opis">Serie: <b>2</b> Episodio: <b>21</b>,&nbsp;</span>
    </td>
    <td align="center">1215</td> <!-- Downloads -->
    <td align="center">1</td>
    <td align="center">23,976</td>
    <td align="center">SubRip</td>
    <td align="center">
      <a href="/it/ppodnapisi/search/sA/226856" 
        title="Show author subtitles by grzesiek11">grzesiek11</a>
    </td>
    <td align="center">01.05.2013</td>
  </tr>
</table>
      HTML
  end

  def subtitle_details_page
    <<-HTML
    <div class="box" style="padding-top: 5px;">
      <a href="/it/ppodnapisi/download/i/2382735/k/path-to-zip">
        <img src="/images/simple/downloadS.gif" alt="" 
             onmouseover="src='/images/simple/downloadT.gif'" 
             onmouseout="src='/images/simple/downloadS.gif'" 
             title="Download">&nbsp;
        <h1>Download</h1>
      </a>
    </div>
    HTML
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

  def a_zip_with filename, contents
    buf = ''
    Zip::Archive.open_buffer(buf, Zip::CREATE) do |archive|
      archive.add_buffer filename, contents
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
