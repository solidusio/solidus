module Spree
  class ShippingRate < Spree::Base
    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method, -> { with_deleted }, class_name: 'Spree::ShippingMethod', inverse_of: :shipping_rates
    belongs_to :tax_rate, -> { with_deleted }, class_name: 'Spree::TaxRate'

    has_many :adjustments, as: :adjustable, inverse_of: :adjustable, dependent: :delete_all

    delegate :order, :currency, :order_id, to: :shipment
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
      return price if adjustments.tax.empty? || amount == 0

      tax_explanations = adjustments.tax.map { |tax_adjustment| tax_explain(tax_adjustment) }.join(", ")

      Spree.t :display_price_with_explanations,
              scope: 'shipping_rate.display_price',
              price: price,
              explanations: tax_explanations
    end

    alias_method :display_cost, :display_price

    def eligible?
      false
    end

    private

    def tax_explain(adjustment)
      tax_rate = adjustment.source
      Spree.t translation_key(adjustment),
              scope: 'shipping_rate.display_price.tax_explanations',
              tax_amount: display_tax_amount(adjustment),
              tax_rate_name: tax_rate.name
    end

    def display_tax_amount(adjustment)
      Spree::Money.new(adjustment.amount.abs, currency: currency)
    end

    def translation_key(adjustment)
      if adjustment.source.included_in_price?
        if adjustment.amount > 0
          :vat
        else
          :vat_refund
        end
      else
        :sales_tax
      end
    end
  end
end
