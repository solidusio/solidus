# frozen_string_literal: true

module Spree
  # Records the costs of different shipping methods for a shipment and which
  # method has been selected to deliver the shipment.
  #
  class ShippingRate < Spree::Base
    belongs_to :shipment, class_name: "Spree::Shipment", touch: true, optional: true
    belongs_to :shipping_method, -> { with_discarded }, class_name: "Spree::ShippingMethod", inverse_of: :shipping_rates, optional: true

    has_many :taxes,
      class_name: "Spree::ShippingRateTax",
      inverse_of: :shipping_rate,
      dependent: :destroy

    delegate :order, :currency, to: :shipment
    delegate :name, :tax_category, :tax_category_id, to: :shipping_method
    delegate :code, to: :shipping_method, prefix: true
    alias_attribute :amount, :cost
    alias_attribute :total_before_tax, :cost

    extend DisplayMoney
    money_methods :amount

    def display_price
      price = display_amount.to_s

      return price if taxes.to_a.empty? || amount == 0

      tax_explanations = taxes.map(&:label).join(tax_label_separator)

      I18n.t "spree.shipping_rate.display_price.display_price_with_explanations",
        price:,
        explanations: tax_explanations
    end
    alias_method :display_cost, :display_price

    private

    def tax_label_separator
      I18n.t "spree.shipping_rate.display_price.tax_label_separator"
    end
  end
end
