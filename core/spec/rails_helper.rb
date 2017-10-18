require 'db_helper'

ENV["RAILS_ENV"] ||= 'test'
ENV["LIB_NAME"] = 'solidus_core'

require 'rspec-activemodel-mocks'

# enable auto loading
require 'active_support'
require 'active_support/dependencies'
relative_load_paths = %w[app/models app/models/concerns app/mailers app/jobs]
ActiveSupport::Dependencies.autoload_paths += relative_load_paths

require 'rails/all'
require 'database_cleaner'
require 'timecop'

require 'spree/core'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'cancan/matchers'

# provides mock_model/stub_model, will want to remove eventually.
require 'rspec/active_model/mocks'

# manually load our i18n. We have tests that require it.
I18n.config.load_path += [File.join('config', 'locales', 'en.yml')]

# since we aren't loading a full rails app, we need to init paperclip ourselves
ActiveRecord::Base.send(:include, Paperclip::Glue)

# set paperclip to interpolate rails_root, since we don't have one
# sans rails
Paperclip.interpolates :rails_root do |attachment, style|
  'tmp'
end


ActiveJob::Base.queue_adapter = :test

require 'rspec/rails/matchers/active_job'

ActionMailer::Base.perform_deliveries = false

Rails.cache = ActiveSupport::Cache::MemoryStore.new

RSpec.configure do |config|
  config.before :each do
    Rails.cache.clear
  end

  config.include RSpec::Rails::Matchers
  config.include ActiveJob::TestHelper
  config.include FactoryBot::Syntax::Methods
end
