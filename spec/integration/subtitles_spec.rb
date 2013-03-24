require 'mechanize'
require 'pry'

class SubTitlesClient
  def search text
    agent = Mechanize.new
    agent.get 'http://www.sub-titles.net/' do |page|
        form = page.form_with( :name => 'sf3') do |search|
          search.sK = text
        end
        return form.submit.body
    end
  end

  def parse html
    @doc = Nokogiri::HTML(html)
  end
  def subtitles
    return @doc.css('tr.a td').map do |cell|
      ResultRow.new cell
    end
  end

end
class ResultRow
  def initialize cell
    @cell = cell
  end
  def title()    @cell.css('a[2]').text                    end
  def href()     @cell.css('a[2]').attribute('href').value end
  def filename() @cell.css('span.opis[1]').text            end
  def season()   @cell.css('span.opis[2] b[1]').text       end
  def episode()  @cell.css('span.opis[2] b[2]').text       end
end

describe SubTitlesClient do
  it 'should search for tv series subtitles' do
    client = SubTitlesClient.new
    client.parse File.read('spec/fixtures/subtitles-search-result.html')
    subtitle = client.subtitles.first

    expect(subtitle.title).to eq 'The 4400 (2004)'
    expect(subtitle.filename).to eq 'The.4400.S02E06.DSR.XviD-TCM.'
    expect(subtitle.season).to eq '2'
    expect(subtitle.episode).to eq '6'
    expect(subtitle.href).to eq '/en/ppodnapisi/podnapis/i/2192291/the-4400-2004-undertexter'
  end
end
