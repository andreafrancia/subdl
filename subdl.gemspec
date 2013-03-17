Gem::Specification.new do |s|
  s.name        = 'subdl'
  s.version     = '0.0.4'
  s.date        = '2013-03-14'
  s.summary     = "Download subtitles for your favorite show."
  s.description = "A simple hello world gem"
  s.authors     = ["Andrea Francia"]
  s.email       = 'andrea@andreafrancia.it'
  s.files       = ["lib/subdl.rb"]
  s.homepage    = 'https://github.com/andreafrancia/subdl'
  s.executables << 'subdl'
  s.add_runtime_dependency 'mechanize'
  s.add_runtime_dependency 'zipruby'
  s.add_runtime_dependency 'json'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
