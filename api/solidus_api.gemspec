# frozen_string_literal: true

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

  gem.required_ruby_version = '>= 2.4.0'
  gem.required_rubygems_version = '>= 1.8.23'

  gem.add_dependency 'jbuilder', '~> 2.8'
  gem.add_dependency 'kaminari-activerecord', '~> 1.1'
  gem.add_dependency 'responders'
  gem.add_dependency 'solidus_core', gem.version
end
