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

  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|bin)/})
  end

  s.required_ruby_version = '>= 3.2.0'
  s.required_rubygems_version = '>= 1.8.23'

  %w[
    actionmailer actionpack actionview activejob activemodel activerecord
    activestorage activesupport railties
  ].each do |rails_dep|
    s.add_dependency rails_dep, [
      ">= #{Spree.minimum_required_rails_version}",
      "< 8.2"
    ]
  end

  s.add_dependency 'activemerchant', '~> 1.66'
  s.add_dependency 'acts_as_list', '< 2.0'
  s.add_dependency 'awesome_nested_set', ['~> 3.3', '>= 3.7.0']
  s.add_dependency 'cancancan', ['>= 2.2', '< 4.0']
  s.add_dependency 'carmen', '~> 1.1.0'
  s.add_dependency 'db-query-matchers', '~> 0.14'
  s.add_dependency 'discard', '~> 1.0'
  s.add_dependency 'friendly_id', '~> 5.0'
  s.add_dependency 'image_processing', '~> 1.10'
  s.add_dependency 'kaminari-activerecord', '~> 1.1'
  s.add_dependency 'mini_magick', '~> 4.10'
  s.add_dependency 'monetize', '~> 1.8'
  s.add_dependency 'kt-paperclip', ['>= 6.3', '< 8']
  s.add_dependency 'psych', ['>= 4.0.1', '< 6.0']
  s.add_dependency 'ransack', ['~> 4.0', '< 5']
  s.add_dependency 'state_machines', ['~> 0.6', '< 0.10.0']
  s.add_dependency 'state_machines-activerecord', ['~> 0.6', '< 0.10.0']
  s.add_dependency 'omnes', '~> 0.2.2'

  s.post_install_message = <<-MSG
-------------------------------------------------------------
                Thank you for using Solidus
-------------------------------------------------------------
If this is a fresh install, don't forget to run the Solidus
installer with the following command:

$ bin/rails g solidus:install

If you are updating Solidus from an older version, please run
the following commands to complete the update:

$ bin/rails g solidus:update

Please, don't forget to look at the CHANGELOG to see what has changed and
whether you need to perform other tasks.

https://github.com/solidusio/solidus/blob/main/CHANGELOG.md

Please report any issues at:
- https://github.com/solidusio/solidus/issues
- http://slack.solidus.io/
-------------------------------------------------------------
MSG
end
