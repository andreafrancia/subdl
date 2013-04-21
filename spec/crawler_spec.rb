require 'subdl'

describe Crawler do
  let(:crawler)      { Crawler.new itasa, credentials }
  let(:credentials)  { double 'credentials' }
  let(:itasa)        { double 'itasa' }

  it 'should search and download subtitles' do
    credentials.stub(read:["pippo", "secret"])
    itasa.stub(:search).with('The Show 1x03').and_return(['the-id'])
    itasa.should_receive(:login).with('pippo', 'secret')
    itasa.should_receive(:download_zip).with('the-id')

    crawler.download_sub_for '/home/user/The.Show.S01E03.mp4'
  end

end

