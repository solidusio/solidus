# encoding: UTF-8
require_relative 'core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus'
  s.version     = Spree.solidus_version
  s.summary     = 'Full-stack e-commerce framework for Ruby on Rails.'
  s.description = 'Solidus is an open source e-commerce framework for Ruby on Rails.'

  s.files        = Dir['README.md', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'
  s.required_ruby_version     = '>= 2.1.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.author       = 'Solidus Team'
  s.email        = 'contact@solidus.io'
  s.homepage     = 'http://solidus.io'
  s.license      = 'BSD-3'

  s.add_dependency 'solidus_core', s.version
  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_backend', s.version
  s.add_dependency 'solidus_frontend', s.version
  s.add_dependency 'solidus_sample', s.version
end
