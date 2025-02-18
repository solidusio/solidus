# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end
  SimpleCov.command_name("solidus:backend")
  SimpleCov.merge_timeout(3600)
  SimpleCov.start("rails")
end

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= "test"

require "solidus_backend"
require "spree/testing_support/dummy_app"
DummyApp.setup(
  gem_root: File.expand_path("..", __dir__),
  lib_name: "solidus_backend"
)

require "rails-controller-testing"
require "rspec-activemodel-mocks"
require "rspec/rails"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require "database_cleaner"

require "spree/testing_support/factory_bot"
require "spree/testing_support/partial_double_verification"
require "spree/testing_support/authorization_helpers"
require "spree/testing_support/preferences"
require "spree/testing_support/controller_requests"
require "spree/testing_support/flaky"
require "spree/testing_support/flash"
require "spree/testing_support/url_helpers"
require "spree/testing_support/order_walkthrough"
require "spree/testing_support/capybara_ext"
require "spree/testing_support/precompiled_assets"
require "spree/testing_support/translations"
require "spree/testing_support/job_helpers"
require "spree/testing_support/blacklist_urls"
require "spree/testing_support/silence_deprecations"

require "capybara-screenshot/rspec"
Capybara.save_path = ENV["CIRCLE_ARTIFACTS"] if ENV["CIRCLE_ARTIFACTS"]
Capybara.exact = true

require "selenium/webdriver"

Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--headless"
  browser_options.args << "--disable-gpu"
  browser_options.args << "--window-size=1920,1080"
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
Capybara.register_driver :selenium_chrome_headless_docker_friendly do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--headless"
  browser_options.args << "--disable-gpu"
  # Sandbox cannot be used inside unprivileged Docker container
  browser_options.args << "--no-sandbox"
  browser_options.args << "--window-size=1240,1400"
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.javascript_driver = (ENV["CAPYBARA_DRIVER"] || :selenium_chrome_headless).to_sym

Rails.application.config.i18n.raise_on_missing_translations = true

Capybara.default_max_wait_time = ENV["DEFAULT_MAX_WAIT_TIME"].to_f if ENV["DEFAULT_MAX_WAIT_TIME"].present?

ActiveJob::Base.queue_adapter = :test

Spree::TestingSupport::FactoryBot.add_paths_and_load!

RSpec.configure do |config|
  config.color = true
  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.fixture_path = "spec/fixtures"

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    Rails.cache.clear
  end

  config.include BaseFeatureHelper, type: :feature
  config.include BaseFeatureHelper, type: :system

  config.include FactoryBot::Syntax::Methods

  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::TestingSupport::Flash
  config.include Spree::TestingSupport::Translations
  config.include Spree::TestingSupport::JobHelpers
  config.include Spree::TestingSupport::BlacklistUrls

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.order = :random

  Kernel.srand config.seed
end
