# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'netica/version'

Gem::Specification.new do |gem|
  gem.name          = "netica"
  gem.version       = Netica::VERSION
  gem.authors       = ["Jerry Richardson"]
  gem.email         = ["jerry@jerryr.com"]
  gem.description   = "Exploration Tools for SimScientists"
  gem.summary       = "Exploration Tools for SimScientists"
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
end
