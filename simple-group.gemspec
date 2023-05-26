Gem::Specification.new do |s|
  s.name          = 'simple-group'
  s.version       = '0.5'
  s.summary       = 'A database built upon JSON files'
  s.author        = 'John Labovitz'
  s.email         = 'johnl@johnlabovitz.com'
  s.description   = %q{
    Group is a database built upon JSON files.
  }.strip
  s.license       = 'MIT'
  s.homepage      = 'http://github.com/jslabovitz/simple-group'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path  = 'lib'

  s.add_dependency 'json', '~> 2.6'
  s.add_dependency 'path', '~> 2.1'
  s.add_dependency 'set_params', '~> 0.2'

  s.add_development_dependency 'bundler', '~> 2.4'
  s.add_development_dependency 'minitest', '~> 5.18'
  s.add_development_dependency 'minitest-power_assert', '~> 0.3'
  s.add_development_dependency 'rake', '~> 13.0'


end