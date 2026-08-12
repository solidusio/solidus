# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] ||= "test"

require "solidus_i18n"
require "spree/testing_support/dummy_app"
DummyApp.setup(
  gem_root: File.expand_path("..", __dir__),
  lib_name: "solidus_i18n"
)

require "rspec/rails"

RSpec.configure do |config|
  if ENV["GITHUB_ACTIONS"]
    require "rspec/github"
    config.add_formatter RSpec::Github::Formatter
  end
  config.filter_run_when_matching :focus
  config.raise_errors_for_deprecations!
end
