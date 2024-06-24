# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "spec_helper"
require "solidus_legacy_promotions"

# Run Coverage report
require "solidus_dev_support/rspec/coverage"
# SOLIDUS DUMMY APP
require "spree/testing_support/dummy_app"
DummyApp.setup(
  gem_root: File.expand_path("..", __dir__),
  lib_name: "solidus_friendly_promotions"
)

# Calling `draw` will completely rewrite the routes defined in the dummy app,
# so we need to include the main solidus route.
DummyApp::Application.routes.draw do
  mount SolidusAdmin::Engine, at: "/admin", constraints: ->(req) {
    req.cookies["solidus_admin"] == "true" ||
      req.params["solidus_admin"] == "true" ||
      SolidusFriendlyPromotions.config.use_new_admin?
  }
  mount SolidusFriendlyPromotions::Engine, at: "/"
  mount Spree::Core::Engine, at: "/"
end

# Turbo will try to autoload ActionCable if we allow `app/channels`.
# Backport of https://github.com/hotwired/turbo-rails/pull/601
# Can go once `turbo-rails` 2.0.7 is released.
Rails.autoloaders.once.do_not_eager_load("#{Turbo::Engine.root}/app/channels")

require "solidus_admin/testing_support/admin_assets"

# AXE - ACCESSIBILITY
require "axe-rspec"
require "axe-capybara"
# Requires factories and other useful helpers defined in spree_core.
require "solidus_dev_support/rspec/feature_helper"
# Feature helpers for the new admin
require "solidus_admin/testing_support/feature_helpers"
require "shoulda-matchers"
# Explicitly load activemodel mocks
require "rspec-activemodel-mocks"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Requires factories defined in Solidus core and this extension.
# See: lib/solidus_friendly_promotions/testing_support/factories.rb
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusFriendlyPromotions::Engine)

Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
Spree::Config.promotions = SolidusFriendlyPromotions.configuration

# Allow Capybara to find elements by aria-label attributes
Capybara.enable_aria_label = true

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.include SolidusFriendlyPromotions::Engine.routes.url_helpers, type: :request

  config.around :each, :solidus_admin, :js do |example|
    SolidusFriendlyPromotions.config.use_new_admin = true
    example.run
    SolidusFriendlyPromotions.config.use_new_admin = false
  end
  config.include SolidusAdmin::TestingSupport::FeatureHelpers, type: :feature, solidus_admin: true
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
