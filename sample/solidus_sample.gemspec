# frozen_string_literal: true

require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_sample'
  s.version     = Spree.solidus_version
  s.summary     = 'Sample data (including images) for use with Solidus.'
  s.description = s.summary

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3-Clause'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|script)/})
  end

  s.required_ruby_version = '>= 2.5.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'solidus_core', s.version
end
