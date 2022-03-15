# frozen_string_literal: true

module Spree
  module Discounts
    class ShipmentDiscounter
      attr_reader :promotions

      def initialize(promotions:)
        @promotions = promotions
      end

      def call(shipment)
        discounts = promotions.select do |promotion|
          promotion.eligible_rules(shipment)
        end.flat_map do |promotion|
          promotion.actions.select do |action|
            action.can_discount? Spree::Shipment
          end.map do |action|
            action.discount(shipment)
          end
        end

        chosen_discounts = Spree::Config.discount_chooser_class.new(shipment).call(discounts)
        shipment.discounts = chosen_discounts
      end
    end
  end
end
