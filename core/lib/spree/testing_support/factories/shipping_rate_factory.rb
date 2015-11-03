FactoryGirl.define do
  factory :shipping_rate, class: Spree::ShippingRate do
    shipping_method
    shipment
  end
end
