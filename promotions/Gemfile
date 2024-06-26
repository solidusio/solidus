# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch("SOLIDUS_BRANCH", "main")
gem "solidus", github: "solidusio/solidus", branch: branch

# The solidus_frontend gem has been pulled out since v3.2
gem "solidus_frontend", github: "solidusio/solidus_frontend" if branch == "master"
gem "solidus_frontend" if branch >= "v3.2" # rubocop:disable Bundler/DuplicatedGem

# Needed to help Bundler figure out how to resolve dependencies,
# otherwise it takes forever to resolve them.
# See https://github.com/bundler/bundler/issues/6677
gem "rails", ">0.a"

# Provides basic authentication functionality for testing parts of your engine
gem "solidus_auth_devise"

gem "solidus_admin", github: "solidusio/solidus", branch: branch
gem "axe-core-rspec", "~> 4.8", require: false
gem "axe-core-capybara", "~> 4.8", require: false

case ENV.fetch("DB", nil)
when "mysql"
  gem "mysql2"
when "postgresql"
  gem "pg"
else
  gem "sqlite3", "~> 1.3"
end

gemspec

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g. pry-byebug.
#
# We use `send` instead of calling `eval_gemfile` to work around an issue with
# how Dependabot parses projects: https://github.com/dependabot/dependabot-core/issues/1658.
send(:eval_gemfile, "Gemfile-local") if File.exist? "Gemfile-local"
