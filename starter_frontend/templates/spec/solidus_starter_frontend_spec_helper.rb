# frozen_string_literal: true

require 'rails_helper'

require 'rails-controller-testing'
require 'rspec/active_model/mocks'

require "view_component/test_helpers"

require 'rspec/rails'
require 'factory_bot'
require 'ffaker'

require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/preferences'
require 'spree/testing_support/caching'
require 'spree/testing_support/order_walkthrough'
require 'spree/testing_support/translations'

# Define the namespace for the helpers.
module SolidusStarterFrontend; end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/solidus_starter_frontend/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec
  config.color = true
  config.fail_fast = ENV.fetch('FAIL_FAST', false)
  config.order = 'random'
  config.example_status_persistence_file_path = "./spec/examples.txt"

  Kernel.srand config.seed

  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::Translations
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include ActiveJob::TestHelper

  config.before do
    ActiveJob::Base.queue_adapter = :test
  end

  config.after(:suite) do
    Rails.autoloaders.main.class.eager_load_all
  rescue NameError => e
    raise <<~WARN
      Zeitwerk raised the following error when trying to eager load your extension:

      #{e.message}
    WARN
  end

  # We currently have examples wherein we mock or stub method that do not exist on
  # the real objects.
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false
  end

  config.before(:each, with_signed_in_user: true) do
    sign_in(user)
  end

  config.before(:each, with_guest_session: true) do
    allow_any_instance_of(ActionDispatch::Cookies::CookieJar).to receive(:signed) { { guest_token: order.guest_token } }
  end

  config.around(:each, caching: true) do |example|
    original_cache_store = ActionController::Base.cache_store
    ActionController::Base.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

    example.run

    Rails.cache.clear
    ActionController::Base.cache_store = original_cache_store
  end
end
