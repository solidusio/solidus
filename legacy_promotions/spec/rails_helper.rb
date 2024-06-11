# frozen_string_literal: true

require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

# SOLIDUS DUMMY APP
require 'spree/testing_support/dummy_app'
DummyApp.setup(
  gem_root: File.expand_path('..', __dir__),
  lib_name: 'solidus_legacy_promotions'
)

DummyApp.mattr_accessor :use_solidus_admin

# Calling `draw` will completely rewrite the routes defined in the dummy app,
# so we need to include the main solidus route.
DummyApp::Application.routes.draw do
  mount SolidusAdmin::Engine, at: "/admin", constraints: ->(_req) {
    DummyApp.use_solidus_admin
  }
  mount Spree::Core::Engine, at: "/"
end

unless SolidusAdmin::Engine.root.join('app/assets/builds/solidus_admin/tailwind.css').exist?
  Dir.chdir(SolidusAdmin::Engine.root) do
    system 'bundle exec rake tailwindcss:build' or abort 'Failed to build Tailwind CSS'
  end
end

require 'rails-controller-testing'
require 'rspec/rails'
require 'rspec-activemodel-mocks'
require 'database_cleaner'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require 'spree/testing_support/factory_bot'
require 'spree/testing_support/preferences'
require 'spree/testing_support/rake'
require 'spree/testing_support/job_helpers'
require 'spree/api/testing_support/helpers'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/controller_requests'
require "solidus_admin/testing_support/feature_helpers"
require 'cancan/matchers'
require 'spree/testing_support/capybara_ext'

require "selenium/webdriver"

ActiveJob::Base.queue_adapter = :test

Spree::TestingSupport::FactoryBot.add_paths_and_load!

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

# AXE - ACCESSIBILITY
require 'axe-rspec'
require 'axe-capybara'

Capybara.javascript_driver = (ENV['CAPYBARA_DRIVER'] || :selenium_chrome_headless).to_sym

# VIEW COMPONENTS
Rails.application.config.view_component.test_controller = "SolidusAdmin::BaseController"
require "view_component/test_helpers"

RSpec.configure do |config|
  config.fixture_path = File.join(__dir__, "fixtures")

  config.infer_spec_type_from_file_location!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before :suite do
    FileUtils.rm_rf(Rails.configuration.active_storage.service_configurations[:test][:root]) unless ENV['DISABLE_ACTIVE_STORAGE'] == 'true'
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    Rails.cache.clear
  end

  config.around :each, :solidus_admin do |example|
    DummyApp.use_solidus_admin = true
    example.run
    DummyApp.use_solidus_admin = false
  end

  config.include ViewComponent::TestHelpers, type: :component

  config.include Spree::TestingSupport::JobHelpers
  config.include SolidusAdmin::TestingSupport::FeatureHelpers, type: :feature
  config.include FactoryBot::Syntax::Methods
  config.include Spree::Api::TestingSupport::Helpers, type: :request
  config.include Spree::TestingSupport::UrlHelpers, type: :controller
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
end
