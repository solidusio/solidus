if ENV["COVERAGE"]
  # Run Coverage report
  require 'simplecov'
  SimpleCov.start do
    add_group 'Controllers', 'app/controllers'
    add_group 'Helpers', 'app/helpers'
    add_group 'Mailers', 'app/mailers'
    add_group 'Models', 'app/models'
    add_group 'Views', 'app/views'
    add_group 'Jobs', 'app/jobs'
    add_group 'Libraries', 'lib'
  end
end

require 'spree/testing_support/preferences'
require 'spree/config'
require 'with_model'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.color = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    reset_spree_preferences
  end

  config.include Spree::TestingSupport::Preferences
  config.extend WithModel

  config.fail_fast = ENV['FAIL_FAST'] || false

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.order = :random

  Kernel.srand config.seed
end
