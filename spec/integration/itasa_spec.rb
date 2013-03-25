require 'rspec-expectations'
require 'subdl'

describe Itasa do
  let(:itasa) { Itasa.new }

  describe 'a new itasa' do
    it 'should not have been logged yet' do
      itasa.should_not be_logged_in
    end
    it 'should login' do
      itasa = Itasa.new
      credentials = Credentials.new.read
      itasa.login *credentials
      itasa.should be_logged_in
    end
    it 'should discover ids' do
      found_ids = itasa.search 'The Simpsons 24x15' 
      found_ids.should == ['40039', '40038', '40037']
    end
  end
end

