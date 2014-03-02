require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'i18n-spec'
require 'ffaker'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'database_cleaner'

Dir[File.join(File.dirname(__FILE__), '/support/**/*.rb')].each {|f| require f}

require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  # config.filter_run focus: true

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::ControllerRequests

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    I18n.locale = I18n.default_locale
  end

  config.before do
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # Capybara.javascript_driver = :poltergeist
end
