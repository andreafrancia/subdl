require 'rspec-expectations'
require 'subdl'

describe Itasa do

  let(:agent) { double 'itasa' }
  let(:itasa) { Itasa.new agent }

  it 'should discover ids' do

    agent.should_receive(:get).with("http://www.italiansubs.net/" +
      "modules/mod_itasalivesearch/search.php?term=The+Simpsons+24x15").
      and_return Struct.new(:body).new(<<EOF)
[{"value":"The Simpsons 24x15 WEB-DL","id":"40039"},{"value":"The Simpsons 24x15 720p","id":"40038"},{"value":"The Simpsons 24x15 ","id":"40037"}]
EOF

    found_ids = itasa.search_subtitles 'The Simpsons 24x15'
    found_ids.should == ['40039', '40038', '40037']
  end

end

