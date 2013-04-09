describe Subdl do
  it 'should downlaod subtitles' do
    agent = double 'agent'
    subdl = Subdl.new agent
  end
  # User stories:
  #  - tell which page it is reading
  #  - download subtitles from Itasa
  #  - downlaod english subtitles from sub-titles.net upon request
  #  - download english subtitles because Itasa subtitles cannot be found
  #  - download english subtitles because Itasa subtitles cannot be downloaded
  #  - downlaod italian subtitles from sub-titles in order to not get Itasa
  #    count increased
  #  - ask credentials to the user
  #  - preserve original filename from zip
  #  - gui and drag and drop
  #  - support movies
  #  - should issue a warning when the file does not exists


end
