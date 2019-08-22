# frozen_string_literal: true

module Spree
  # Used to persist shipping rate tax estimations.
  # @attr [Spree::ShippingRate] shipping_rate The shipping rate to be taxed
  # @attr [Spree::TaxRate] tax_rate The tax rate used to calculate the tax amount
  # @since 1.3.0
  # @see Spree::Tax::ShippingRateTaxer
  class ShippingRateTax < ActiveRecord::Base
    belongs_to :shipping_rate, class_name: "Spree::ShippingRate", optional: true
    belongs_to :tax_rate, class_name: "Spree::TaxRate", optional: true

    extend DisplayMoney
    money_methods :absolute_amount

    delegate :currency, to: :shipping_rate, allow_nil: true

    def label
      I18n.t translation_key,
        scope: 'spree.shipping_rate_tax.label',
        amount: display_absolute_amount,
        tax_rate_name: tax_rate.name
    end

    def absolute_amount
      amount.abs
    end

    private

    def translation_key
      if tax_rate.included_in_price?
         :vat
       else
         :sales_tax
      end
    end
  end
end
