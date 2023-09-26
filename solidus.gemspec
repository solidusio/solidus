# frozen_string_literal: true

require_relative 'core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus'
  s.version     = Spree.solidus_version
  s.summary     = 'Full-stack e-commerce framework for Ruby on Rails.'
  s.description = 'Solidus is an open source e-commerce framework for Ruby on Rails.'

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3-Clause'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = Dir['README.md', 'lib/**/*']

  s.required_ruby_version = '>= 3.0.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'solidus_admin'
  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_backend', s.version
  s.add_dependency 'solidus_core', s.version
  s.add_dependency 'solidus_sample', s.version
end
