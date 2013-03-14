require 'rspec-expectations'
require 'crawler'

describe Itasa do
  let(:itasa) { Itasa.new }
  let(:logged_itasa) { 
    itasa = Itasa.new 
    Credentials.new.read_to itasa
    itasa
  }
  describe 'a new itasa' do
    it 'should not have been logged yet' do
      itasa.should_not be_logged_in
    end
    it 'should login' do
      logged_itasa.should be_logged_in
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


end

