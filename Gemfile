# frozen_string_literal: true

source 'https://rubygems.org'

gemspec require: false

# rubocop:disable Bundler/DuplicatedGem
if ENV['RAILS_VERSION'] == 'master'
  gem 'rails', github: 'rails', require: false
else
  gem 'rails', ENV['RAILS_VERSION'] || '~> 7.0.2', require: false
end
# rubocop:enable Bundler/DuplicatedGem

# Temporarily locking sprockets to v3.x
# see https://github.com/solidusio/solidus/issues/3374
# and https://github.com/rails/sprockets-rails/issues/369
gem 'sprockets', '~> 3'

dbs = ENV['DB_ALL'] ? 'all' : ENV.fetch('DB', 'sqlite')
gem 'mysql2', '~> 0.5.0', require: false if dbs.match?(/all|mysql/)
gem 'pg', '~> 1.0', require: false if dbs.match?(/all|postgres/)
gem 'fast_sqlite', require: false if dbs.match?(/all|sqlite/)

gem 'database_cleaner', '~> 1.3', require: false
gem 'rspec-activemodel-mocks', '~> 1.1', require: false
gem 'rspec-rails', '~> 4.0.1', require: false
gem 'rspec-retry', '~> 0.6.2', require: false
gem 'simplecov', require: false
gem 'simplecov-cobertura', require: false
gem 'rails-controller-testing', require: false
gem 'puma', '< 6', require: false
gem 'i18n-tasks', '~> 0.9', require: false

# Ensure the requirement is also updated in core/lib/spree/testing_support/factory_bot.rb
gem 'factory_bot_rails', '>= 4.8', require: false

group :backend do
  gem 'capybara', '~> 3.13', require: false
  gem 'capybara-screenshot', '>= 1.0.18', require: false
  gem 'selenium-webdriver', require: false
  gem 'webdrivers', require: false

  # JavaScript testing
  gem 'teaspoon', github: 'jejacks0n/teaspoon', require: false
  gem 'teaspoon-mocha', github: 'jejacks0n/teaspoon', require: false
  gem 'webrick', require: false
end

group :utils do
  gem 'pry'
  gem 'launchy', require: false
  gem 'rubocop', '~> 1', require: false
  gem 'rubocop-performance', '~> 1.4', require: false
  gem 'rubocop-rails', '~> 2.9', require: false
  gem 'gem-release', require: false
end

gem 'rspec_junit_formatter', require: false, group: :ci

# Documentation
gem 'yard', require: false, group: :docs

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval File.read(custom_gemfile), nil, custom_gemfile, 0 if File.exist?(custom_gemfile)
