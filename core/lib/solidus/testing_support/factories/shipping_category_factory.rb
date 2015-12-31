FactoryGirl.define do
  factory :shipping_category, class: Solidus::ShippingCategory do
    sequence(:name) { |n| "ShippingCategory ##{n}" }
  end
end
