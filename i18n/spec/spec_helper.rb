ENV["RAILS_ENV"] = "test"

require 'yaml'
require 'rspec'
require 'i18n'
require 'i18n-spec'
require 'i18n/core_ext/hash'
require 'active_support/core_ext/kernel/reporting'
require 'support/fake_app'
require 'support/be_a_thorough_translation_of_matcher'

RSpec.configure do |config|
  config.mock_with :rspec
  config.fail_fast = true
end
