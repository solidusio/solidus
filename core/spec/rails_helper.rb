require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'
ENV["LIB_NAME"] = 'solidus_core'

require 'spree/testing_support/dummy_app'
DummyApp::Migrations.auto_migrate

require 'rspec/rails'
require 'rspec-activemodel-mocks'
require 'database_cleaner'
require 'timecop'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'cancan/matchers'

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.fixture_path = File.join(File.expand_path(File.dirname(__FILE__)), "fixtures")

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
