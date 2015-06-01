FactoryGirl.define do
  factory :shipping_rate, class: Spree::ShippingRate do
    shipment_id nil
    cost 10
  end
end
