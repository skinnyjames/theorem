Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.7.5'
  s.name        = 'theorem'
  s.version     = '0.0.2'
  s.licenses    = ['MIT']
  s.summary     = 'simple. testing. ah.'
  s.description = 'simple. testing. ah.'
  s.authors     = ['Sean Gregory']
  s.email       = 'sean.christopher.gregory@gmail.com'
  s.files       = Dir['src/**/*.rb']
  s.bindir = 'bin'
  s.executables << 'theorize'
  s.require_paths = ['lib']
  s.homepage    = 'https://rubygems.org/gems/theorem'
  s.metadata    = { 'source_code_uri' => 'https://github.com/skinnyjames/theorem' }
  s.add_dependency 'extended_dir'
  s.add_development_dependency 'rbs'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'watir'
end