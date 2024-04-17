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
    f.match(%r{^(spec|script)/})
  end

  s.required_ruby_version = '>= 3.0.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'solidus_core', s.version
  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_backend', s.version
  s.add_dependency 'solidus_support'
end
