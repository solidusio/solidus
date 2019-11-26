# frozen_string_literal: true

require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_core'
  s.version     = Spree.solidus_version
  s.summary     = 'Essential models, mailers, and classes for the Solidus e-commerce project.'
  s.description = s.summary

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3-Clause'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'

  s.required_ruby_version = '>= 2.4.0'
  s.required_rubygems_version = '>= 1.8.23'

  %w[
    actionmailer actionpack actionview activejob activemodel activerecord
    activesupport railties
  ].each do |rails_dep|
    s.add_dependency rails_dep, ['>= 5.1', '< 7.0.x']
  end

  s.add_dependency 'activemerchant', '~> 1.66'
  s.add_dependency 'acts_as_list', '~> 0.3'
  s.add_dependency 'awesome_nested_set', '~> 3.2'
  s.add_dependency 'cancancan', ['>= 2.2', '< 4.0']
  s.add_dependency 'carmen', '~> 1.1.0'
  s.add_dependency 'discard', '~> 1.0'
  s.add_dependency 'friendly_id', '~> 5.0'
  s.add_dependency 'kaminari-activerecord', '~> 1.1'
  s.add_dependency 'monetize', '~> 1.8'
  s.add_dependency 'paperclip', '>= 4.2'
  s.add_dependency 'paranoia', '~> 2.4'
  s.add_dependency 'ransack', '~> 2.0'
  s.add_dependency 'state_machines-activerecord', '~> 0.6'
end
