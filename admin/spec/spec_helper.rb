# frozen_string_literal: true

# SIMPLECOV
if ENV["COVERAGE"]
  require 'simplecov'
  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end
  SimpleCov.command_name('solidus:admin')
  SimpleCov.merge_timeout(3600)
  SimpleCov.start('rails')
end

require 'solidus_admin'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# SOLIDUS DUMMY APP
require 'spree/testing_support/dummy_app'
DummyApp.setup(
  gem_root: File.expand_path('..', __dir__),
  lib_name: 'solidus_admin'
)

# RAILS
require "rspec/rails"
ENV["RAILS_ENV"] ||= 'test'
Rails.application.config.i18n.raise_on_missing_translations = true

# CAPYBARA & SELENIUM
require "capybara/rspec"
require 'capybara-screenshot/rspec'
require "selenium/webdriver"
require 'webdrivers'
Capybara.save_path = ENV['CIRCLE_ARTIFACTS'] if ENV['CIRCLE_ARTIFACTS']
Capybara.exact = true
Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--window-size=1920,1080'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
Capybara.register_driver :selenium_chrome_headless_docker_friendly do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  # Sandbox cannot be used inside unprivileged Docker container
  browser_options.args << '--no-sandbox'
  browser_options.args << '--window-size=1240,1400'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
Capybara.javascript_driver = (ENV['CAPYBARA_DRIVER'] || :selenium_chrome_headless).to_sym
Capybara.default_max_wait_time = ENV['DEFAULT_MAX_WAIT_TIME'].to_f if ENV['DEFAULT_MAX_WAIT_TIME'].present?

# DATABASE CLEANER
require 'database_cleaner'

# FACTORY BOT
require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.add_paths_and_load!

# VIEW COMPONENTS
require "view_component/test_helpers"
require "view_component/system_test_helpers"

# GENERATORS
require "rails/version"
require "rails/generators"
require "rails/generators/app_base"
require "rails/generators/testing/behaviour"

RSpec.configure do |config|
  config.color = true
  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = true

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    Rails.cache.clear
  end

  config.include Capybara::RSpecMatchers, type: :component

  config.include FactoryBot::Syntax::Methods

  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component

  config.include Rails::Generators::Testing::Behaviour, type: :generator
  config.include FileUtils, type: :generator
  config.before type: :generator do
    self.generator_class = described_class
    self.destination_root = SolidusAdmin::Engine.root.join('tmp')
    ::Rails::Generators.namespace = SolidusAdmin
    prepare_destination
  end

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.order = :random

  Kernel.srand config.seed
end
