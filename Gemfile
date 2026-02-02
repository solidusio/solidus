# frozen_string_literal: true

source 'https://rubygems.org'

gemspec require: false

# rubocop:disable Bundler/DuplicatedGem
if /(stable|main)/.match? ENV['RAILS_VERSION']
  gem 'rails', github: 'rails', require: false, branch: ENV['RAILS_VERSION']
else
  gem 'rails', ENV['RAILS_VERSION'] || ['> 7.0', '< 8.2'], require: false
end
# rubocop:enable Bundler/DuplicatedGem

gem "debug"
gem 'launchy', require: false

dbs = ENV['DB_ALL'] ? 'all' : ENV.fetch('DB', 'sqlite')
gem 'mysql2', '~> 0.5.0', require: false if dbs.match?(/all|mysql/)
gem 'pg', '~> 1.0', require: false if dbs.match?(/all|postgres/)
gem 'fast_sqlite', require: false if dbs.match?(/all|sqlite/)
gem 'sqlite3', '>= 2.1', require: false if dbs.match?(/all|sqlite/)

gem 'benchmark', '~> 0.5', require: false
gem 'database_cleaner', '~> 2.0', require: false
gem 'rspec-activemodel-mocks', '~> 1.1', require: false
gem 'rspec-rails', '~> 6.0.3', require: false
gem 'rspec-retry', '~> 0.6.2', require: false
gem 'simplecov', require: false
gem 'simplecov-cobertura', require: false
gem 'rack', '< 3', require: false
gem 'rake', require: false, groups: [:lint, :release]
gem 'rails-controller-testing', require: false
gem 'puma', '< 7', require: false
gem 'i18n-tasks', '~> 1.1.0', require: false
gem 'rspec_junit_formatter', require: false
gem 'yard', require: false
gem 'db-query-matchers', require: false

if ENV['GITHUB_ACTIONS']
  gem "rspec-github", "~> 3.0", require: false
end

# Ensure the requirement is also updated in core/lib/spree/testing_support/factory_bot.rb
gem 'factory_bot_rails', '>= 4.8', require: false

group :backend do
  gem 'capybara', '~> 3.13', require: false
  gem 'capybara-screenshot', '>= 1.0.18', require: false
  gem 'selenium-webdriver', require: false

  # JavaScript testing
  gem 'teaspoon', require: false
  gem 'teaspoon-mocha', require: false
  gem 'webrick', require: false
end

group :admin do
  gem 'tailwindcss-rails', '~> 3.0', require: false
end

group :admin, :legacy_promotions, :promotions do
  gem 'solidus_admin', path: 'admin', require: false
  gem 'axe-core-rspec', '~> 4.8', require: false
  gem 'axe-core-capybara', '~> 4.8', require: false
end

group :legacy_promotions, :promotions do
  gem 'solidus_legacy_promotions', path: 'legacy_promotions', require: false
  gem 'solidus_backend', path: 'backend', require: false
end

group :promotions do
  gem 'solidus_promotions', path: 'promotions', require: false
  gem 'shoulda-matchers', '~> 5.0', require: false
end

group :lint do
  gem 'erb-formatter', '~> 0.7', require: false
  gem 'rubocop', '~> 1', require: false
  gem 'rubocop-performance', '~> 1.4', require: false
  gem 'rubocop-rails', '~> 2.9', require: false
end

group :release do
  gem 'octokit', '~> 7.1', require: false
  gem 'faraday-retry', '~> 2.0', require: false
end

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval File.read(custom_gemfile), nil, custom_gemfile, 0 if File.exist?(custom_gemfile)
