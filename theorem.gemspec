Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.7.5'
  s.name        = 'theorem'
  s.version     = '1.2.0'
  s.licenses    = ['MIT']
  s.summary     = 'simple and extensible test library toolkit'
  s.description = 'simple and extensible test library toolkit'
  s.authors     = ['Sean Gregory']
  s.email       = 'sean.christopher.gregory@gmail.com'
  s.files       = Dir['src/**/*.rb']
  s.bindir = 'bin'
  s.executables << 'theorize'
  s.require_paths = ['src']
  s.homepage    = 'https://rubygems.org/gems/theorem'
  s.metadata    = { 'source_code_uri' => 'https://gitlab.com/skinnyjames/theorem' }
  s.add_dependency 'extended_dir', '~> 0.1.1'
  s.add_dependency 'slop', '~> 4.9.2'

  s.add_development_dependency 'rbs'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rubocop'
end
