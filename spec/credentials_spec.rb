require 'subdl'

describe Credentials do
  it 'should parse credentials file' do
    credentials = Credentials.new nil
    result = credentials.parse "username\npassword"
    result.should == ['username', 'password']
  end
end


