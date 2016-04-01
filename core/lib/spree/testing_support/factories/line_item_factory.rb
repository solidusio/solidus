require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/product_factory'

FactoryGirl.define do
  factory :line_item, class: Spree::LineItem do
    quantity 1
    price { BigDecimal.new('10.00') }
    order
    transient do
      product nil
    end
    variant do
      (product || create(:product)).master
    end
    currency { order.currency }
  end
end
