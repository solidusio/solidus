# frozen_string_literal: true

# SIMPLECOV
if ENV["COVERAGE"]
  require 'simplecov'
  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end
  if ENV["GITHUB_ACTIONS"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
  SimpleCov.command_name('solidus:admin')
  SimpleCov.merge_timeout(3600)
  SimpleCov.start('rails') do
    add_filter '/shared_examples/'
  end
end

require 'solidus_admin'
require 'rails-controller-testing'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# SOLIDUS DUMMY APP
require 'spree/testing_support/dummy_app'
DummyApp.setup(
  gem_root: File.expand_path('..', __dir__),
  lib_name: 'solidus_admin'
)

# Calling `draw` will completely rewrite the routes defined in the dummy app,
# so we need to include the main solidus route.
DummyApp::Application.routes.draw do
  mount SolidusAdmin::Engine, at: '/admin'
  mount Spree::Core::Engine, at: '/'
end

require "solidus_admin/testing_support/admin_assets"

# RAILS
require "rspec/rails"
ENV["RAILS_ENV"] ||= 'test'
Rails.application.config.i18n.raise_on_missing_translations = true

# CAPYBARA & SELENIUM
require "capybara/rspec"
require 'capybara-screenshot/rspec'
require "spree/testing_support/capybara_driver"

Capybara.save_path = ENV['CIRCLE_ARTIFACTS'] if ENV['CIRCLE_ARTIFACTS']
Capybara.exact = true
Capybara.disable_animation = true
Capybara.default_max_wait_time = ENV['DEFAULT_MAX_WAIT_TIME'].to_f if ENV['DEFAULT_MAX_WAIT_TIME'].present?
Capybara.enable_aria_label = true

# DATABASE CLEANER
require 'database_cleaner'

# FACTORY BOT
require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.add_paths_and_load!

# VIEW COMPONENTS
Rails.application.config.view_component.test_controller = "SolidusAdmin::BaseController"
require "view_component/test_helpers"
require "view_component/system_test_helpers"

# GENERATORS
require "rails/version"
require "rails/generators"
require "rails/generators/app_base"
require "rails/generators/testing/behavior"
require "solidus_admin/testing_support/component_helpers"
require "solidus_admin/testing_support/feature_helpers"

# AXE - ACCESSIBILITY
require 'axe-rspec'
require 'axe-capybara'

# DB Query Matchers
require "db-query-matchers"
DBQueryMatchers.configure do |config|
  config.ignores = [/SHOW TABLES LIKE/]
  config.ignore_cached = true
  config.schemaless = true
end

RSpec.configure do |config|
  if ENV["GITHUB_ACTIONS"]
    require "rspec/github"
    config.add_formatter RSpec::Github::Formatter
  end

  config.color = true
  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
    c.verify_partial_doubles = true
  end

  config.use_transactional_fixtures = true

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    Rails.cache.clear
  end
  config.define_derived_metadata(file_path: %r{spec/features}) do |metadata|
    metadata[:solidus_admin] = true
  end

  config.include FactoryBot::Syntax::Methods

  config.include SolidusAdmin::TestingSupport::FeatureHelpers, type: :feature

  config.include Capybara::RSpecMatchers, type: :component
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include SolidusAdmin::TestingSupport::ComponentHelpers, type: :component

  config.include Rails::Generators::Testing::Behavior, type: :generator
  config.include FileUtils, type: :generator
  config.before type: :generator do
    self.generator_class = described_class
    self.destination_root = SolidusAdmin::Engine.root.join('../tmp/solidus_admin_generators')
    ::Rails::Generators.namespace = SolidusAdmin
    prepare_destination
  end

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.order = :random

  Kernel.srand config.seed
end
