require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/product_factory'

FactoryGirl.define do
  factory :line_item, class: Spree::LineItem do
    quantity 1
    price { variant.price }
    order
    transient do
      product nil
    end
    variant do
      (product || create(:product)).master
    end
  end
end
