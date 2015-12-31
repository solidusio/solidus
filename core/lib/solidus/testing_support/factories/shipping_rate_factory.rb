FactoryGirl.define do
  factory :shipping_rate, class: Solidus::ShippingRate do
    shipping_method
    shipment
  end
end
