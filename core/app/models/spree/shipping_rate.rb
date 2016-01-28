module Spree
  class ShippingRate < Spree::Base
    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method, -> { with_deleted }, class_name: 'Spree::ShippingMethod', inverse_of: :shipping_rates
    belongs_to :tax_rate, -> { with_deleted }, class_name: 'Spree::TaxRate'

    has_many :adjustments, as: :adjustable, inverse_of: :adjustable, dependent: :delete_all

    delegate :order, :currency, to: :shipment
    delegate :name, :tax_category, to: :shipping_method
    delegate :code, to: :shipping_method, prefix: true

    alias_attribute :amount, :cost

    def discounted_amount
      cost
    end

    def display_base_price
      Spree::Money.new(cost, currency: currency)
    end

    def calculate_tax_amount
      tax_rate.calculator.compute_shipping_rate(self)
    end

    def display_price
      price = display_base_price.to_s
      if tax_rate
        tax_amount = calculate_tax_amount
        if tax_amount != 0
          if tax_rate.included_in_price?
            if tax_amount > 0
              amount = "#{display_tax_amount(tax_amount)} #{tax_rate.name}"
              price += " (#{Spree.t(:incl)} #{amount})"
            else
              amount = "#{display_tax_amount(tax_amount * -1)} #{tax_rate.name}"
              price += " (#{Spree.t(:excl)} #{amount})"
            end
          else
            amount = "#{display_tax_amount(tax_amount)} #{tax_rate.name}"
            price += " (+ #{amount})"
          end
        end
      end
      price
    end
    alias_method :display_cost, :display_price

    def display_tax_amount(tax_amount)
      Spree::Money.new(tax_amount, currency: currency)
    end
  end
end
