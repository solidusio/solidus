require 'spec_helper'

require 'database_cleaner'
require 'factory_girl'

require 'active_record'

ActiveRecord::Base.establish_connection ENV['DATABASE_URL']

require 'logger'
ActiveRecord::Base.logger = Logger.new('test.log')

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
