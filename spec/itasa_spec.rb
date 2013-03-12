require 'rspec-expectations'
require 'crawler'
class Itasa

end

describe Itasa do
  let(:itasa) { Itasa.new }
  let(:logged_itasa) { 
    itasa = Itasa.new 
    Credentials.read_to itasa
    itasa
  }
  describe 'a new itasa' do
    it 'should not have been logged yet' do
      itasa.should_not be_logged_in
    end
    it 'should login' do
      Credentials.read_to itasa
      itasa.should be_logged_in
    end
  end

  it 'should discover ids' do
    ids = []
    itasa.each_id 'The Simpsons 24x15' do |id, value|
      ids << [id, value]
    end
    ids.should == [['40039', "The Simpsons 24x15 WEB-DL"],
                   ['40038', "The Simpsons 24x15 720p"],
                   ['40037', "The Simpsons 24x15 "]]
  end

  it 'should download and unpack subtitle' do
    directory = double

    directory.should_receive(:save) do |filename, contents|
      filename.should == 'The.Simpsons.s24e15.WEB-DL.sub.itasa.srt'
      contents.should include('00:20:34,106 --> 00:20:35,473')
    end

    logged_itasa.unpack_subtitle_to '40039', directory

  end

end

