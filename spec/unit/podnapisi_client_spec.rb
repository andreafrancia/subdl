require 'subdl/podnapisi_client'

describe PodnapisiClient do
  let(:client) { PodnapisiClient.new }
  context 'subtitles details page' do
    it 'should parse location to zip' do
      client.parse File.read('spec/fixtures/podnapisi-details-page.html')
      expect(client.zip_location).to eq '/en/ppodnapisi/download/i/1655415/k/2a90f7d65306efde18117ddefab31391052c2660'
    end
  end
  context 'search result page' do
    before :each do
      client.parse File.read('spec/fixtures/podnapisi-search-result.html')
      @subtitle = client.subtitles.first
    end
    it 'should parse title' do 
      expect(@subtitle.title).to eq 'The 4400 (2004)'
    end
    it 'should parse filename' do
      expect(@subtitle.filename).to eq 'The.4400.S02E06.DSR.XviD-TCM.'
    end
    it 'should parse season' do
      expect(@subtitle.season).to eq '2'
    end
    it 'should parse episode' do
      expect(@subtitle.episode).to eq '6'
    end
    it 'should parse link' do
      expect(@subtitle.href).to eq '/en/ppodnapisi/podnapis/i/2192291/the-4400-2004-undertexter'
    end
  end
end
