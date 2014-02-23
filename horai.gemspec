# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = 'horai'
  spec.version     = '0.7.1'
  spec.authors     = ['AOKI Yuuto']
  spec.email       = ['aoki@u-ne.co']
  spec.summary     = %q{Derive DateTime from Time expression with Natural language}
  spec.description = %q{Derive DateTime from Time expression with Natural language (STILL ONLY IN JAPANESE)}
  spec.homepage    = 'http://github.com/wneko/horai'
  spec.licenses    = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'i18n', '>= 0.6.0'
  spec.add_runtime_dependency 'activesupport', '>= 3.0.0'
  spec.add_runtime_dependency 'rparsec-ruby19', '>= 1.0'

  spec.add_development_dependency 'rspec', '~> 2.8.0'
  spec.add_development_dependency 'rdoc', '~> 3.12'
  spec.add_development_dependency 'guard-shell', '>= 0'
  spec.add_development_dependency 'guard-rspec', '>= 0'
  spec.add_development_dependency 'pry', '>= 0'
end
