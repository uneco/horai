lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'horai/version'

Gem::Specification.new do |spec|
  spec.name          = 'horai'
  spec.version       = Horai::VERSION
  spec.authors       = ['uneco', 'mitukiii']
  spec.email         = ['aoki@limbate.com']
  spec.summary       = 'Derive DateTime from Time expression with Natural language (currently, Japanese only)'
  spec.description   = 'Horai は日本語の時刻表現をパースし、DateTime型に変換することを目標としている Gem です。(beta) '
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'i18n', '>= 0.6.0'
  spec.add_runtime_dependency 'activesupport', '>= 3.0.0'
  spec.add_runtime_dependency 'rparsec-ruby19', '>= 1.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'timecop'
end
