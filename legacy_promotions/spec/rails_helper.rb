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
require "solidus_admin/testing_support/admin_assets"

require 'rails-controller-testing'
require 'rspec/rails'
require 'rspec-activemodel-mocks'
require 'database_cleaner'
require 'db-query-matchers'

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
require 'solidus_legacy_promotions/testing_support/factory_bot'
require 'cancan/matchers'
require 'spree/testing_support/capybara_ext'

ActiveJob::Base.queue_adapter = :test

Spree::TestingSupport::FactoryBot.add_paths_and_load!

require "spree/testing_support/capybara_driver"

# AXE - ACCESSIBILITY
require 'axe-rspec'
require 'axe-capybara'

Capybara.enable_aria_label = true

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

  config.include ActiveJob::TestHelper
  config.include SolidusAdmin::TestingSupport::FeatureHelpers, type: :feature
  config.include FactoryBot::Syntax::Methods
  config.include Spree::Api::TestingSupport::Helpers, type: :request
  config.include Spree::TestingSupport::UrlHelpers, type: :controller
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
end
