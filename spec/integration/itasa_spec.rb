require 'rspec-expectations'
require 'subdl'

describe Itasa do
  let(:itasa) { Itasa.new mechanize_agent}

  it 'should login' do
    itasa.should_not be_logged_in
    credentials = Credentials.new.read
    itasa.login *credentials
    itasa.should be_logged_in
  end
  it 'should discover ids' do
    found_ids = itasa.search 'The Simpsons 24x15'
    found_ids.should == ['40039', '40038', '40037']
  end
end

