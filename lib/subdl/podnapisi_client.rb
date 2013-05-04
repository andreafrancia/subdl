require 'mechanize'
require 'nokogiri'

class DetailsPage
  def initialize html
    @doc = Nokogiri::HTML(html)
  end

  def zip_location
    box = @doc.css('div.box')
    box.css('a @href').first.value
  end
end

class SearchResults
  def initialize html
    @doc = Nokogiri::HTML(html)
  end

  def subtitles
    return @doc.css('tr.a td').map do |cell|
      SearchResultRow.new cell
    end
  end

  class SearchResultRow
    def initialize cell
      @cell = cell
    end
    def title
      @cell.xpath('.//a[position()=2]').text
    end
    def href
      @cell.xpath('.//a[position()=2]/@href').text
    end
    def filename
      @cell.xpath(".//span[@class='opis'][1]").text
    end
    def season()
      @cell.xpath(".//span[@class='opis'][2]/b[1]").text
    end
    def episode()
      @cell.xpath(".//span[@class='opis'][2]/b[2]").text
    end
  end
end

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
end
