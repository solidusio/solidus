# frozen_string_literal: true

require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'spree/testing_support/dummy_app'
DummyApp.setup(
  gem_root: File.expand_path('..', __dir__),
  lib_name: 'solidus_legacy_promotions'
)

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
require 'cancan/matchers'
require 'spree/testing_support/capybara_ext'

ActiveJob::Base.queue_adapter = :test

Spree::TestingSupport::FactoryBot.add_paths_and_load!

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

  config.include Spree::TestingSupport::JobHelpers

  config.include FactoryBot::Syntax::Methods
  config.include Spree::Api::TestingSupport::Helpers, type: :request
  config.include Spree::TestingSupport::UrlHelpers, type: :controller
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
end
