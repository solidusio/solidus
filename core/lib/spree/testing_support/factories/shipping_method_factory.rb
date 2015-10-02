require 'spree/testing_support/factories/calculator_factory'
require 'spree/testing_support/factories/shipping_category_factory'
require 'spree/testing_support/factories/zone_factory'

FactoryGirl.define do
  factory(
    :shipping_method,
    aliases: [
      :base_shipping_method
    ],
    class: Spree::ShippingMethod
  ) do
    zones do
      [Spree::Zone.find_by(name: 'GlobalZone') || FactoryGirl.create(:global_zone)]
    end

    name 'UPS Ground'
    code 'UPS_GROUND'

    calculator { |s| s.association(:shipping_calculator, strategy: :build, preferred_amount: s.cost) }

    transient do
      cost 10.0
    end

    before(:create) do |shipping_method, evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (Spree::ShippingCategory.first || create(:shipping_category))
      end
    end

    after(:create) do |shipping_method, evaluator|
      if shipping_method.stock_locations.empty?
        shipping_method.stock_locations << (Spree::StockLocation.all.to_a)
      end
    end

    factory :shipping_method, class: Spree::ShippingMethod do
      transient do
        cost 10.0
      end

      calculator { |s| s.association(:shipping_calculator, strategy: :build, preferred_amount: s.cost) }
    end

>>>>>>> Implication inferred in existing Spree shops
    factory :free_shipping_method, class: Spree::ShippingMethod do
      cost nil
      association(:calculator, factory: :shipping_no_amount_calculator, strategy: :build)
    end
  end
end
