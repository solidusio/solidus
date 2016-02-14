# -*- encoding: utf-8 -*-
require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |gem|
  gem.author        = 'Solidus Team'
  gem.email         = 'contact@solidus.io'
  gem.homepage      = 'http://solidus.io/'

  gem.summary       = 'REST API for the Solidus e-commerce framework.'
  gem.description   = gem.summary

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "solidus_api"
  gem.require_paths = ["lib"]
  gem.version = Spree.solidus_version

  gem.add_dependency 'solidus_core', gem.version
  gem.add_dependency 'rabl', ['>= 0.9.4.pre1', '< 0.12.0']
  gem.add_dependency 'versioncake', '~> 3.0'
end
