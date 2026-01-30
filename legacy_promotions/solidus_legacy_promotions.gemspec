# frozen_string_literal: true

require_relative '../core/lib/spree/core/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_legacy_promotions'
  s.version     = Spree.solidus_version
  s.summary     = 'Legacy Solidus promotion system'
  s.description = s.summary

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3-Clause'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|bin)/})
  end

  s.required_ruby_version = '>= 3.2.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'csv', '~> 3.0'
  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_core', s.version
  s.add_dependency 'solidus_support', '>= 0.13.1', '< 1'
end
