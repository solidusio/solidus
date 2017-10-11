# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'

require 'solidus_sample'
require 'spree/testing_support/dummy_app'
require 'spree/testing_support/dummy_app/auto_migrate'

require 'rspec/rails'
require 'ffaker'

RSpec.configure do |config|
  config.color = true
  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include FactoryBot::Syntax::Methods
  config.fail_fast = ENV['FAIL_FAST'] || false

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.order = :random

  Kernel.srand config.seed
end
