RSpec.configure do |config|
  config.before(:suite) do |example|
    DatabaseCleaner.start
    factories_to_lint = FactoryGirl.factories.reject do |factory|
     [:stock_packer, :customer_return_without_return_items].include?(factory.name)
    end

    FactoryGirl.lint factories_to_lint
    DatabaseCleaner.clean
  end
end
