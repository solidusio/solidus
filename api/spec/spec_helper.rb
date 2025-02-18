# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end
  SimpleCov.command_name("solidus:api")
  SimpleCov.merge_timeout(3600)
  SimpleCov.start("rails")
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"

require "solidus_api"
require "spree/testing_support/dummy_app"
DummyApp.setup(
  gem_root: File.expand_path("..", __dir__),
  lib_name: "solidus_api"
)

require "rails-controller-testing"
require "rspec/rails"
require "rspec-activemodel-mocks"

require "database_cleaner"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

require "spree/testing_support/factory_bot"
require "spree/testing_support/partial_double_verification"
require "spree/testing_support/preferences"
require "spree/testing_support/authorization_helpers"
require "spree/testing_support/job_helpers"

require "spree/api/testing_support/caching"
require "spree/api/testing_support/helpers"
require "spree/api/testing_support/setup"

ActiveJob::Base.queue_adapter = :test

Spree::TestingSupport::FactoryBot.add_paths_and_load!

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [/gems\/activesupport/, /gems\/actionpack/, /gems\/rspec/]
  config.color = true
  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods
  config.include Spree::Api::TestingSupport::Helpers, type: :request
  config.extend Spree::Api::TestingSupport::Setup, type: :request
  config.include Spree::Api::TestingSupport::Helpers, type: :controller
  config.extend Spree::Api::TestingSupport::Setup, type: :controller
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::JobHelpers

  config.before(:each) do
    Rails.cache.clear
  end

  config.use_transactional_fixtures = true

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.order = :random

  Kernel.srand config.seed
end
