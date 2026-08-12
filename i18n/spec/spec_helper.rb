# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# Run Coverage report
require "solidus_dev_support/rspec/coverage"

# Create the dummy app if it's still missing.
dummy_env = "#{__dir__}/dummy/config/environment.rb"
system "bin/rake extension:test_app" unless File.exist? dummy_env
require dummy_env

# Requires factories and other useful helpers defined in spree_core.
require "solidus_dev_support/rspec/feature_helper"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Requires factories defined in Solidus core and this extension.
# See: lib/solidus_i18n/testing_support/factories.rb
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusI18n::Engine)

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
  config.use_transactional_fixtures = false

  if Spree.solidus_gem_version < Gem::Version.new("2.11")
    config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :system
  end
end
