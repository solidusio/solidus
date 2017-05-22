RSpec.configure do |config|
  config.before(:suite) do |example|
    DatabaseCleaner.start
    FactoryGirl.lint
    DatabaseCleaner.clean
  end
end
