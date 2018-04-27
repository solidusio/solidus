# frozen_string_literal: true

source 'https://rubygems.org'

gemspec require: false

rails_version = ENV['RAILS_VERSION'] || '~> 5.2.0'
gem 'rails', rails_version, require: false

platforms :ruby do
  gem 'mysql2', '~> 0.5.0', require: false
  gem 'pg', '~> 1.0', require: false
  gem 'sqlite3', require: false
  gem 'fast_sqlite', require: false
end

platforms :jruby do
  gem 'jruby-openssl', require: false
  gem 'activerecord-jdbcsqlite3-adapter', require: false
end

gem 'database_cleaner', '~> 1.3', require: false
gem 'factory_bot_rails', '~> 4.8', require: false
gem 'rspec-activemodel-mocks', '~>1.0.2', require: false
gem 'rspec-rails', '~> 3.7', require: false
gem 'simplecov', require: false
gem 'with_model', require: false
gem 'rails-controller-testing', require: false

group :backend, :frontend do
  gem 'capybara', '~> 2.15', require: false
  gem 'capybara-screenshot', '>= 1.0.18', require: false
  gem 'selenium-webdriver', require: false
  gem 'poltergeist', '~> 1.9', require: false
end

group :frontend do
  gem 'generator_spec'
end

group :backend do
  gem 'teaspoon', require: false
  gem 'teaspoon-mocha', require: false
end

gem 'rubocop', '~> 0.53.0', require: false

group :utils do
  gem 'pry'
  gem 'launchy', require: false
end

gem 'rspec_junit_formatter', require: false, group: :ci

# Documentation
gem 'yard'

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval File.read(custom_gemfile) if File.exist?(custom_gemfile)
