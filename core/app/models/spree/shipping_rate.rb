module Spree
  class ShippingRate < Spree::Base
    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method, -> { with_deleted }, class_name: 'Spree::ShippingMethod', inverse_of: :shipping_rates

    has_many :taxes,
             class_name: "Spree::ShippingRateTax",
             foreign_key: "shipping_rate_id",
             dependent: :destroy

    delegate :order, :currency, to: :shipment
    delegate :name, :tax_category, to: :shipping_method
    delegate :code, to: :shipping_method, prefix: true
    alias_attribute :amount, :cost

    alias_method :discounted_amount, :amount

    extend DisplayMoney
    money_methods :amount

    def display_price
      price = display_amount.to_s

      return price if taxes.empty? || amount == 0

      tax_explanations = taxes.map(&:label).join(tax_label_separator)

      Spree.t :display_price_with_explanations,
               scope: 'shipping_rate.display_price',
               price: price,
               explanations: tax_explanations
    end
    alias_method :display_cost, :display_price

    private

    def tax_label_separator
      Spree.t :tax_label_separator, scope: 'shipping_rate.display_price'
    end
  end
end
