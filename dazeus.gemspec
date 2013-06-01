# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dazeus/version'

Gem::Specification.new do |gem|
  gem.name          = "dazeus"
  gem.version       = Dazeus::VERSION
  gem.authors       = ["Ruben Nijveld"]
  gem.email         = ["ruben@gewooniets.nl"]
  gem.description   = %q{Ruby bindings for DaZeus}
  gem.summary       = %q{Ruby bindings for DaZeus}
  gem.homepage      = "https://github.com/dazeus/dazeus-ruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
end
