require 'subdl/subtitles_net'

describe DetailsPage do
  it 'should parse location to zip' do
    page = DetailsPage.new File.read('spec/fixtures/podnapisi-details-page.html')
    expect(page.zip_location).to eq '/en/ppodnapisi/download/i/1655415/k/2a90f7d65306efde18117ddefab31391052c2660'
  end
end

