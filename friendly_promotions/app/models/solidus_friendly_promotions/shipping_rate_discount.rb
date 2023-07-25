# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ShippingRateDiscount < Spree::Base
    belongs_to :shipping_rate, inverse_of: :discounts, class_name: "Spree::ShippingRate"
    belongs_to :promotion_action, -> { with_discarded }, inverse_of: false

    extend Spree::DisplayMoney
    money_methods :amount
  end
end
