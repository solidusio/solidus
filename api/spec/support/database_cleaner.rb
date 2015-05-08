RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    # create the default stock location outside of the spec transactions but
    # after truncation so that it's preserved between specs.
    Spree::Fixtures.instance.stock_locations.default
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
