# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch("SOLIDUS_BRANCH", "main")
gem "solidus", github: "solidusio/solidus", branch: branch

# The solidus_frontend gem has been pulled out since v3.2
if branch >= "v3.2"
  gem "solidus_frontend"
elsif branch == "main"
  gem "solidus_frontend", github: "solidusio/solidus_frontend"
else
  gem "solidus_frontend", github: "solidusio/solidus", branch: branch
end

rails_version = ENV.fetch("RAILS_VERSION", "7.0")
gem "rails", "~> #{rails_version}"

case ENV.fetch("DB", nil)
when "mysql"
  gem "mysql2"
when "postgresql"
  gem "pg"
else
  gem "sqlite3", (rails_version < "7.2") ? "~> 1.4" : "~> 2.0"
end

if rails_version == "7.0"
  gem "concurrent-ruby", "< 1.3.5"
end

# While we still support Ruby < 3 we need to workaround a limitation in
# the 'async' gem that relies on the latest ruby, since RubyGems doesn't
# resolve gems based on the required ruby version.
gem "async", "< 3" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3")

group :development, :test do
  gem "i18n-tasks", "~> 0.9" if branch == "main"
end

gemspec

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g. pry-byebug.
#
# We use `send` instead of calling `eval_gemfile` to work around an issue with
# how Dependabot parses projects: https://github.com/dependabot/dependabot-core/issues/1658.
send(:eval_gemfile, "Gemfile-local") if File.exist? "Gemfile-local"
