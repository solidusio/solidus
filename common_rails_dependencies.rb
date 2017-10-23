source 'https://rubygems.org'

gem 'coffee-rails'
gem 'sass-rails'

group :test do
  gem 'capybara', '~> 2.7'
  gem 'capybara-screenshot'
  gem 'launchy'
  gem 'poltergeist', '~> 1.9'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end
