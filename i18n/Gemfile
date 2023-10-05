# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'main')
gem 'solidus', github: 'solidusio/solidus', branch: branch

# The solidus_frontend gem has been pulled out since v3.2
if branch >= 'v3.2'
  gem 'solidus_frontend'
elsif branch == 'main'
  gem 'solidus_frontend', github: 'solidusio/solidus_frontend', branch: branch
else
  gem 'solidus_frontend', github: 'solidusio/solidus', branch: branch
end

# Needed to help Bundler figure out how to resolve dependencies,
# otherwise it takes forever to resolve them.
# See https://github.com/bundler/bundler/issues/6677
gem 'rails', '>0.a'

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3'
end

group :development, :test do
  gem 'i18n-tasks', '~> 0.9' if branch == 'main'
end

gemspec

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g.: `gem 'pry-debug'`.
eval_gemfile 'Gemfile-local' if File.exist? 'Gemfile-local'
