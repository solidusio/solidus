require 'spree/testing_support/factories/shipping_method_factory'
require 'spree/testing_support/factories/shipment_factory'

FactoryGirl.define do
  factory :shipping_rate, class: Spree::ShippingRate do
    shipping_method
    shipment
  end
end
