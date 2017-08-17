require 'spree/testing_support/factories/inventory_unit_factory'
require 'spree/testing_support/factories/variant_factory'
require 'spree/testing_support/factories/order_factory'

FactoryGirl.define do
  factory :stock_package, class: Spree::Stock::Package do
    skip_create

    transient do
      order { build(:order) }
      stock_location { build(:stock_location) }
      contents       { [] }
      variants_contents { {} }
    end

    initialize_with { new(order, stock_location, contents) }

    after(:build) do |package, evaluator|
      evaluator.variants_contents.each do |variant, count|
        package.add_multiple build_list(:inventory_unit, count, variant: variant)
      end
    end

    factory :stock_package_fulfilled do
      transient { variants_contents { { build(:variant) => 2 } } }
    end
  end
end
