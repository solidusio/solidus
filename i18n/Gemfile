source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

if branch == 'master' || branch >= "v2.0"
  gem "rails-controller-testing", group: :test
else
  gem "rails_test_params_backport", group: :test
end

gem 'chromedriver-helper' if ENV['CI']

gem 'pg', '~> 0.21'
gem 'sqlite3'
gem 'mysql2', '~> 0.4.10'

group :development, :test do
  gem "pry-rails"
  gem 'i18n-tasks', '~> 0.9' if branch == 'master'
end

gemspec
