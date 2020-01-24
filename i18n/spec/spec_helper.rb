# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] ||= 'test'

# Run Coverage report
require 'solidus_dev_support/rspec/coverage'

require File.expand_path('dummy/config/environment.rb', __dir__)

# Requires factories and other useful helpers defined in spree_core.
require 'solidus_dev_support/rspec/feature_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories defined in lib/solidus_i18n/factories.rb
require 'solidus_i18n/factories'

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
