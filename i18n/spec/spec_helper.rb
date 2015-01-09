require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'

begin
  require File.expand_path('../dummy/config/environment', __FILE__)
rescue LoadError
  puts 'Could not load dummy application. Please ensure you have run `bundle exec rake test_app`'
  exit
end

require 'pry'
require 'ffaker'
require 'rspec/rails'

RSpec.configure do |config|
  config.fail_fast = false
  config.filter_run focus: true
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = false

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end

Dir[File.join(File.dirname(__FILE__), '/support/**/*.rb')].each { |file| require file }
