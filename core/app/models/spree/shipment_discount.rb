# frozen_string_literal: true

module Spree
  class ShipmentDiscount < Spree::Base
    belongs_to :shipment, inverse_of: :discounts
    belongs_to :promotion_action, -> { with_discarded }, inverse_of: :shipment_discounts
  end
end
