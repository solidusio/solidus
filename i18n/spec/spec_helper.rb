ENV["RAILS_ENV"] = "test"

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'i18n-spec'
require 'rspec/rails'
require 'support/be_a_thorough_translation_of_matcher'

RSpec.configure do |config|
  config.mock_with :rspec
end
