# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/inventory_unit_factory'
  require 'spree/testing_support/factories/variant_factory'
end

FactoryBot.define do
  factory :stock_package, class: 'Spree::Stock::Package' do
    skip_create

    transient do
      stock_location { build(:stock_location) }
      contents       { [] }
      variants_contents { {} }
    end

    initialize_with { new(stock_location, contents) }

    after(:build) do |package, evaluator|
      evaluator.variants_contents.each do |variant, count|
        package.add_multiple build_list(:inventory_unit, count, variant: variant, stock_location: evaluator.stock_location)
      end
    end

    factory :stock_package_fulfilled do
      transient { variants_contents { { build(:variant) => 2 } } }
    end
  end
end

