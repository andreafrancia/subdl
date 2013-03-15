require 'subdl'

describe Crawler do
  let(:crawler)      { Crawler.new logged_itasa }
  let(:logged_itasa) { double 'itasa' }

  it 'should search using ids' do
    logged_itasa.should_receive(:each_id).with('The Show 1x03')

    crawler.download_sub_for '/home/user/The.Show.S01E03.mp4'
  end

  it 'should unpack subtitle the rigth sub' do
    logged_itasa.stub(:each_id).with('The Show 1x03').
      and_yield('the-id', 'unused show name')
    logged_itasa.should_receive(:unpack_subtitle_to).with('the-id', anything)

    crawler.download_sub_for '/home/user/The.Show.S01E03.mp4'
  end

end

