# -*- encoding: utf-8 -*-
require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |gem|
  gem.author        = 'Solidus Team'
  gem.email         = 'contact@solidus.io'
  gem.homepage      = 'http://solidus.io/'
  gem.license       = 'BSD-3-Clause'

  gem.summary       = 'REST API for the Solidus e-commerce framework.'
  gem.description   = gem.summary

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "solidus_api"
  gem.require_paths = ["lib"]
  gem.version = Spree.solidus_version

  gem.required_ruby_version = '>= 2.2.2'
  gem.required_rubygems_version = '>= 1.8.23'

  gem.add_dependency 'solidus_core', gem.version
  gem.add_dependency 'rabl', '0.13.0' # FIXME: update for proper rails 5 support
  gem.add_dependency 'versioncake', '~> 3.0'
end
