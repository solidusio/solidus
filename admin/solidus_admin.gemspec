# frozen_string_literal: true

require_relative '../core/lib/spree/core/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_admin'
  s.version     = Spree.solidus_version
  s.summary     = 'Admin interface for the Solidus e-commerce framework.'
  s.description = s.summary

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3-Clause'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|script)/})
  end

  s.required_ruby_version = '>= 3.0.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'dry-system', '~> 1.0'
  s.add_dependency 'importmap-rails', '~> 1.1'
  s.add_dependency 'solidus_core', s.version
  s.add_dependency 'tailwindcss-rails', '~> 2.0'
  s.add_dependency 'view_component', '~> 3.0'
end
