# By placing all of Spree's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of Spree.
source 'https://rubygems.org'

platforms :ruby do
  # Version restriction because AR will not use mysql2 0.4.0
  # This can be removed when a future version of rails is released
  gem 'mysql2', '~> 0.3.20'
  gem 'pg'
  gem 'sqlite3'
  gem 'fast_sqlite'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter'
end

gem 'coffee-rails'
gem 'sass-rails'

group :test do
  gem 'capybara', '~> 2.4'
  gem 'capybara-screenshot'
  gem 'database_cleaner', '~> 1.3'
  gem 'email_spec'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'launchy'
  gem 'rspec-activemodel-mocks', '~>1.0.2'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 3.3.0'
  gem 'simplecov'
  gem 'webmock', '1.8.11'
  gem 'poltergeist'
  gem 'timecop'
  gem 'with_model'
  gem 'rspec_junit_formatter'
end

group :test, :development do
  platforms :mri do
    gem 'pry-byebug', '~> 1.0'
  end
end
