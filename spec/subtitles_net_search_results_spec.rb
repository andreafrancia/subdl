require 'subdl/subtitles_net'

describe SearchResults do
  let(:client) {
    SearchResults.new( File.read('spec/fixtures/podnapisi-search-result.html')) }
  let(:first_result) { client.subtitles.first }
  it 'should parse title' do
    expect(first_result.title).to eq 'The 4400 (2004)'
  end
  it 'should parse filename' do
    expect(first_result.filename).to eq 'The.4400.S02E06.DSR.XviD-TCM.'
  end
  it 'should parse season' do
    expect(first_result.season).to eq '2'
  end
  it 'should parse episode' do
    expect(first_result.episode).to eq '6'
  end
  it 'should parse link' do
    expect(first_result.href).to eq '/en/ppodnapisi/podnapis/i/2192291/the-4400-2004-undertexter'
  end
end
