# encoding: UTF-8
require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_backend'
  s.version     = Spree.solidus_version
  s.summary     = 'Admin interface for the Solidus e-commerce framework.'
  s.description = s.summary

  s.required_ruby_version = '>= 2.1.0'
  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.rubyforge_project = 'solidus_backend'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_core', s.version

  s.add_dependency 'sass-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'bourbon', '>= 4', '< 6'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails', '~> 5.0.0'
  s.add_dependency 'select2-rails',   '3.5.9.1' # 3.5.9.2 breaks forms
  s.add_dependency 'font-awesome-rails', '~> 4.0'

  s.add_dependency 'handlebars_assets', '~> 0.23'
end
