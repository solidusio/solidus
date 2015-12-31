FactoryGirl.define do
  factory :base_shipping_method, class: Spree::ShippingMethod do
    zones { |a| [Spree::Zone.global] }
    name 'UPS Ground'
    code 'UPS_GROUND'

    before(:create) do |shipping_method, evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (Spree::ShippingCategory.first || create(:shipping_category))
      end
    end

    factory :shipping_method, class: Spree::ShippingMethod do
      transient do
        cost 10.0
      end

      calculator { |s| s.association(:shipping_calculator, strategy: :build, preferred_amount: s.cost) }
    end

    factory :free_shipping_method, class: Spree::ShippingMethod do
      association(:calculator, factory: :shipping_no_amount_calculator, strategy: :build)
    end
  end
end
