# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class CreateDiscountedItem < PromotionAction
      include OrderLevelAction
      preference :variant_id, :integer

      def perform(order)
        line_item = find_item(order) || create_item(order)
        line_item.current_discounts << discount(line_item)
      end

      private

      def find_item(order)
        order.line_items.detect { |line_item| line_item.managed_by_order_action == self }
      end

      def create_item(order)
        order.line_items.create!(quantity: 1, variant: variant, managed_by_order_action: self)
      end

      def variant
        Spree::Variant.find(preferred_variant_id)
      end
    end
  end
end
