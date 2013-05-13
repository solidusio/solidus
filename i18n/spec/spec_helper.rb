ENV["RAILS_ENV"] = "test"

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "/support/**/*.rb")].each {|f| require f}

require 'i18n-spec'
require 'ffaker'
require 'rspec/rails'
require 'support/be_a_thorough_translation_of_matcher'

require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/authorization_helpers'

RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:each) do
    I18n.locale = I18n.default_locale
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::Preferences

  config.extend Spree::TestingSupport::AuthorizationHelpers::Request, type: :feature
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
