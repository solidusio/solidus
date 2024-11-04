# frozen_string_literal: true

require_relative '../core/lib/spree/core/version'
require_relative './lib/solidus_admin/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_admin'
  s.version     = SolidusAdmin::VERSION
  s.summary     = 'Admin interface for the Solidus e-commerce framework.'
  s.description = s.summary

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'https://github.com/solidusio/solidus/blob/main/admin/README.md'
  s.license     = 'BSD-3-Clause'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/solidusio/solidus/tree/main/api"
  s.metadata["changelog_uri"] = "https://github.com/solidusio/solidus/releases?q=%22solidus_admin%2Fv0%22&expanded=true"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|script)/})
  end + ["app/assets/builds/solidus_admin/tailwind.css"]

  s.required_ruby_version = '>= 3.1.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'geared_pagination', '~> 1.1'
  s.add_dependency 'importmap-rails', '~> 1.2', '>= 1.2.1'
  s.add_dependency 'solidus_backend'
  s.add_dependency 'solidus_core', '> 4.2'
  s.add_dependency 'stimulus-rails', '~> 1.2'
  s.add_dependency 'turbo-rails', '~> 2.0'
  s.add_dependency 'view_component', '~> 3.9'
end
