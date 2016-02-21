module Spree
  class ShippingRate < Spree::Base
    include Spree::Tax::TaxHelpers

    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method, -> { with_deleted }, class_name: 'Spree::ShippingMethod', inverse_of: :shipping_rates

    delegate :order, :currency, to: :shipment
    delegate :name, :tax_category, to: :shipping_method
    delegate :code, to: :shipping_method, prefix: true
    alias_attribute :amount, :cost

    def display_base_price
      Spree::Money.new(cost, currency: currency)
    end

    def calculate_tax_amount
      tax_rate.calculator.compute_shipping_rate(self)
    end

    def tax_rates
      applicable_rates.select { |rate| rate.tax_category == tax_category }
    end

    def display_price
      price = display_base_price.to_s

      return price if tax_rates.empty? || amount == 0

      tax_explanations = tax_rates.map { |rate| tax_explain(rate) }.join(", ")

      Spree.t :display_price_with_explanations,
               scope: 'shipping_rate.display_price',
               price: price,
               explanations: tax_explanations
    end
    alias_method :display_cost, :display_price

    def display_tax_amount(tax_amount)
      Spree::Money.new(tax_amount, currency: currency)
    end

    private

    def tax_explain(rate)
      amount = rate.calculator.compute_shipping_rate(self)
      Spree.t translation_key(amount, rate),
        scope: 'shipping_rate.display_price.tax_explanations',
        tax_amount: display_tax_amount(amount.abs),
        tax_rate_name: rate.name
    end

    def translation_key(amount, rate)
      if rate.included_in_price?
        if amount > 0
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
