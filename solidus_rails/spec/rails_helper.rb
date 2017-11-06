require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'

require 'rspec/rails'
require 'database_cleaner'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

if ENV["CHECK_TRANSLATIONS"]
  require "spree/testing_support/i18n"
end

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
