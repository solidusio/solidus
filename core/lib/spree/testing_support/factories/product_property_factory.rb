require 'spree/testing_support/factories/product_factory'
require 'spree/testing_support/factories/property_factory'

FactoryGirl.define do
  factory :product_property, class: Spree::ProductProperty do
    product
    property
  end
end
