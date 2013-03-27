require 'mechanize'

class PodnapisiClient
  def search text, season, episode
    agent = Mechanize.new
    agent.get 'http://www.sub-titles.net/' do |page|
        form = page.form_with( :name => 'sf3') do |search|
          search.sK = text
          search.sTS = season
          search.sTE = episode
          form.field_with(name:'sJ').value=2
          # 2 -> Inglese
          # 9 -> Italiano
        end
        return form.submit.body
    end
  end

  def parse html
    @doc = Nokogiri::HTML(html)
  end
  def subtitles
    return @doc.css('tr.a td').map do |cell|
      SearchResultRow.new cell
    end
  end
  def zip_location
    box = @doc.css('div.box')
    box.css('a @href').first.value
  end

  class SearchResultRow
    def initialize cell
      @cell = cell
    end
    def title()    @cell.css('a[2]').text                    end
    def href()     @cell.css('a[2]').attribute('href').value end
    def filename() @cell.css('span.opis[1]').text            end
    def season()   @cell.css('span.opis[2] b[1]').text       end
    def episode()  @cell.css('span.opis[2] b[2]').text       end
  end
end
