require 'spree/testing_support/factories/stock_location_factory'

FactoryGirl.define do
  # must use build()
  factory :stock_packer, class: Spree::Stock::Packer do
    transient do
      stock_location { build(:stock_location) }
      contents []
    end

    initialize_with { new(stock_location, contents) }
  end
end
