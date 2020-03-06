# frozen_string_literal: true

source 'https://rubygems.org'

group :backend, :frontend, :core, :api do
  gemspec require: false

  # rubocop:disable Bundler/DuplicatedGem
  if ENV['RAILS_VERSION'] == 'master'
    gem 'rails', github: 'rails', require: false
  else
    gem 'rails', ENV['RAILS_VERSION'] || '~> 6.0.0', require: false
  end
  # rubocop:enable Bundler/DuplicatedGem

  # Temporarily locking sprockets to v3.x
  # see https://github.com/solidusio/solidus/issues/3374
  # and https://github.com/rails/sprockets-rails/issues/369
  gem 'sprockets', '~> 3'

  platforms :ruby do
    case ENV['DB']
    when /mysql/
      gem 'mysql2', '~> 0.5.0', require: false
    when /postgres/
      gem 'pg', '~> 1.0', require: false
    else
      gem 'sqlite3', require: false
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
  gem 'rspec-rails', '~> 4.0.0.beta2', require: false
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
  gem 'teaspoon', github: 'jejacks0n/teaspoon', require: false
  gem 'teaspoon-mocha', github: 'jejacks0n/teaspoon', require: false
end

group :utils do
  gem 'pry'
  gem 'launchy', require: false
  gem 'i18n-tasks', '~> 0.9', require: false
  gem 'rubocop', '~> 0.75.0', require: false
  gem 'rubocop-performance', '~> 1.4', require: false
  gem 'rubocop-rails', '~> 2.3', require: false
  gem 'gem-release', require: false
end

gem 'rspec_junit_formatter', require: false, group: :ci

# Documentation
gem 'yard', require: false, group: :docs

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval File.read(custom_gemfile), nil, custom_gemfile, 0 if File.exist?(custom_gemfile)
