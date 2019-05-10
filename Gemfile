# frozen_string_literal: true

source 'https://rubygems.org'

group :backend, :frontend, :core, :api do
  gemspec require: false

  rails_version = ENV['RAILS_VERSION'] || '~> 5.2.0'
  gem 'rails', rails_version, require: false

  platforms :ruby do
    case ENV['DB']
    when /mysql/
      gem 'mysql2', '~> 0.5.0', require: false
    when /postgres/
      gem 'pg', '~> 1.0', require: false
    else
      gem 'sqlite3', '~> 1.3.6', require: false
      gem 'fast_sqlite', require: false
    end
  end

  platforms :jruby do
    gem 'jruby-openssl', require: false
    gem 'activerecord-jdbcsqlite3-adapter', require: false
  end

  gem 'database_cleaner', '~> 1.3', require: false
  gem 'factory_bot_rails', '~> 4.8', require: false
  gem 'rspec-activemodel-mocks', '~> 1.1', require: false
  gem 'rspec-rails', '~> 3.7', require: false
  gem 'simplecov', require: false
  gem 'with_model', require: false
  gem 'rails-controller-testing', require: false
  gem 'puma', require: false
end

group :backend, :frontend do
  gem 'capybara', '~> 3.13', require: false
  gem 'capybara-screenshot', '>= 1.0.18', require: false
  gem 'selenium-webdriver', require: false
end

group :frontend do
  gem 'generator_spec'
end

group :backend do
  gem 'teaspoon', require: false
  gem 'teaspoon-mocha', require: false
end

group :utils do
  gem 'pry'
  gem 'launchy', require: false
  gem 'i18n-tasks', '~> 0.9', require: false
  gem 'rubocop', '~> 0.53.0', require: false
  gem 'gem-release', require: false
end

gem 'rspec_junit_formatter', require: false, group: :ci

# Documentation
gem 'yard', require: false, group: :docs

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval File.read(custom_gemfile), nil, custom_gemfile, 0 if File.exist?(custom_gemfile)
