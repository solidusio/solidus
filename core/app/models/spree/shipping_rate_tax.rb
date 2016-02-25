module Spree
  class ShippingRateTax < ActiveRecord::Base
    belongs_to :shipping_rate, class_name: "Spree::ShippingRate"
    belongs_to :tax_rate, class_name: "Spree::TaxRate"

    extend DisplayMoney
    money_methods :absolute_amount

    def absolute_amount
      amount.abs
    end
  end
end
