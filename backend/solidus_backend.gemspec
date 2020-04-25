# frozen_string_literal: true

require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_backend'
  s.version     = Spree.solidus_version
  s.summary     = 'Admin interface for the Solidus e-commerce framework.'
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

  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_core', s.version

  s.add_dependency 'coffee-rails'
  s.add_dependency 'font-awesome-rails', '~> 4.0'
  s.add_dependency 'jbuilder', '~> 2.8'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'kaminari', '~> 1.1'
  s.add_dependency 'responders'
  s.add_dependency 'sassc-rails'

  s.add_dependency 'autoprefixer-rails'
  s.add_dependency 'handlebars_assets', '~> 0.23'
end
