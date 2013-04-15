ENV["RAILS_ENV"] = "test"

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'i18n-spec'
require 'rspec/rails'
require 'support/be_a_thorough_translation_of_matcher'

require 'spree/testing_support/factories'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'

RSpec.configure do |config|
  config.mock_with :rspec

  config.include FactoryGirl::Syntax::Methods
  config.include Rack::Test::Methods, :type => :requests
  config.include Spree::TestingSupport::UrlHelpers
end
