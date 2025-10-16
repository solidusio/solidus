# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "spec_helper"
require "solidus_legacy_promotions"
require 'db-query-matchers'

# SOLIDUS DUMMY APP
require "spree/testing_support/dummy_app"
DummyApp.setup(
  gem_root: File.expand_path("..", __dir__),
  lib_name: "solidus_promotions"
)

# Calling `draw` will completely rewrite the routes defined in the dummy app,
# so we need to include the main solidus route.
DummyApp::Application.routes.draw do
  mount SolidusAdmin::Engine, at: "/admin", constraints: ->(req) {
    req.cookies["solidus_admin"] == "true" ||
      req.params["solidus_admin"] == "true" ||
      SolidusPromotions.config.use_new_admin?
  }
  mount SolidusPromotions::Engine, at: "/"
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

# Feature helpers for the new admin
require "solidus_admin/testing_support/feature_helpers"
require "shoulda-matchers"
# Explicitly load activemodel mocks
require "rspec-activemodel-mocks"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

require "rspec/rails"
require "database_cleaner"

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require "spree/testing_support/preferences"
require "spree/testing_support/rake"
require "spree/testing_support/job_helpers"
require "spree/api/testing_support/helpers"
require "spree/testing_support/url_helpers"
require "spree/testing_support/authorization_helpers"
require "spree/testing_support/controller_requests"
require "cancan/matchers"
require "spree/testing_support/capybara_ext"

# Requires factories defined in Solidus core and this extension.
# See: lib/solidus_promotions/testing_support/factories.rb
require "spree/testing_support/factory_bot"
require "solidus_legacy_promotions/testing_support/factory_bot"
require "solidus_promotions/testing_support/factory_bot"
Spree::TestingSupport::FactoryBot.add_definitions!
SolidusLegacyPromotions::TestingSupport::FactoryBot.add_definitions!
SolidusPromotions::TestingSupport::FactoryBot.add_paths_and_load!

Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
Spree::Config.promotions = SolidusPromotions.configuration
ActiveJob::Base.queue_adapter = :test

require "spree/testing_support/capybara_driver"

# Allow Capybara to find elements by aria-label attributes
Capybara.enable_aria_label = true

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.include SolidusPromotions::Engine.routes.url_helpers, type: :request
  config.include FactoryBot::Syntax::Methods
  config.include Shoulda::Matchers::ActiveRecord, type: :model

  config.around :each, :solidus_admin do |example|
    SolidusPromotions.config.use_new_admin = true
    example.run
    SolidusPromotions.config.use_new_admin = false
  end

  config.include SolidusAdmin::TestingSupport::FeatureHelpers, type: :feature, solidus_admin: true
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
