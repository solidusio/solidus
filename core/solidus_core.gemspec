# encoding: UTF-8
require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_core'
  s.version     = Spree.solidus_version
  s.summary     = 'Essential models, mailers, and classes for the Solidus e-commerce project.'
  s.description = s.summary

  s.required_ruby_version = '>= 2.1.0'
  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'

  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'activemerchant', '~> 1.48'
  s.add_dependency 'acts_as_list', '~> 0.3'
  s.add_dependency 'awesome_nested_set', '~> 3.0', '>= 3.0.1'
  s.add_dependency 'carmen', '~> 1.0.0'
  s.add_dependency 'cancancan', '~> 1.10'
  s.add_dependency 'ffaker', '~> 2.0'
  s.add_dependency 'friendly_id', '~> 5.0'
  s.add_dependency 'highline', '~> 1.6.18' # Necessary for the install generator
  s.add_dependency 'kaminari', '~> 0.15', '>= 0.15.1'
  s.add_dependency 'monetize', '~> 1.1'
  s.add_dependency 'paperclip', '~> 4.2'
  s.add_dependency 'paranoia', '~> 2.1', '>= 2.1.4'
  s.add_dependency 'premailer-rails'
  s.add_dependency 'rails', '~> 4.2.5'
  s.add_dependency 'ransack', '~> 1.6'
  s.add_dependency 'responders'
  s.add_dependency 'state_machines-activerecord', '~> 0.2'
  s.add_dependency 'stringex', '~> 1.5.1'
  s.add_dependency 'truncate_html', '~> 0.9', '>= 0.9.2'
  s.add_dependency 'twitter_cldr', '~> 3.0'

  s.add_development_dependency 'email_spec', '~> 1.6'
end
