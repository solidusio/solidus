source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

if branch == 'master' || branch >= "v2.0"
  gem "rails-controller-testing", group: :test
end

gem 'pg'
gem 'sqlite3'
gem 'mysql2'

group :development, :test do
  gem "pry-rails"
  gem 'i18n-tasks', '~> 0.9' if branch == 'master'
end

gemspec
