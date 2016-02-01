# By placing all of Spree's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of Spree.
source 'https://rubygems.org'

platforms :ruby do
  gem 'mysql2'
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
  gem 'capybara', '~> 2.7'
  gem 'capybara-screenshot'
  gem 'database_cleaner', '~> 1.3'
  gem 'email_spec'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'launchy'
  gem 'rspec-activemodel-mocks', '~>1.0.2'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => 'master'
  end
  gem 'simplecov'
  gem 'poltergeist', '~> 1.9'
  gem 'timecop'
  gem 'with_model'
  gem 'rspec_junit_formatter'
end

gem 'rails', github: 'rails/rails'
gem 'paranoia', github: 'jhawthorn/paranoia', branch: 'rails5'
gem 'state_machines-activerecord', github: 'state-machines/state_machines-activerecord'
gem 'state_machines-activemodel', github: 'state-machines/state_machines-activemodel'

group :test, :development do
  gem 'rubocop'
  gem 'pry'

  platforms :mri do
    gem 'byebug'
  end
end
