# frozen_string_literal: true

require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'spree/testing_support/dummy_app'
DummyApp.setup(
  gem_root: File.expand_path('..', __dir__),
  lib_name: 'solidus_core'
)

require 'rspec/rails'
require 'rspec-activemodel-mocks'
require 'database_cleaner'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/rake'
require 'cancan/matchers'

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.fixture_path = File.join(__dir__, "fixtures")

  config.infer_spec_type_from_file_location!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    Rails.cache.clear
  end

  config.include ActiveJob::TestHelper
  config.include FactoryBot::Syntax::Methods
end
