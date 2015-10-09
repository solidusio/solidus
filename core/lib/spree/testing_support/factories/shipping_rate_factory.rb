FactoryGirl.define do
  factory :shipping_rate, class: Spree::ShippingRate do
    shipment { nil }
    cost 10
  end
end
