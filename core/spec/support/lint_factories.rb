RSpec.configure do |config|
  config.before(:suite) do |example|
    DatabaseCleaner.start
    factories_to_lint = FactoryGirl.factories.reject do |factory|
      factory.name =~ /^stock_packer$/
    end

    FactoryGirl.lint factories_to_lint
    DatabaseCleaner.clean
  end
end
