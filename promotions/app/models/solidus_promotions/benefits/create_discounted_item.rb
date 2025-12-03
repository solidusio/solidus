# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class CreateDiscountedItem < Benefit
      preference :variant_id, :integer
      preference :quantity, :integer, default: 1
      preference :necessary_quantity, :integer, default: 1

      def perform(order)
        line_item = find_item(order) || build_item(order)
        set_quantity(line_item, determine_item_quantity(order))
        discount_line_item(line_item)
      end

      def remove_from(order)
        find_item(order)&.mark_for_destruction
      end

      def level
        :order
      end
      deprecate :level, deprecator: Spree.deprecator

      private

      def discount_line_item(line_item, ...)
        adjustment = find_adjustment(line_item) || build_adjustment(line_item)
        adjustment.amount = compute_amount(line_item, ...)
        adjustment.label = adjustment_label(line_item)
        adjustment
      end

      def find_adjustment(line_item)
        line_item.adjustments.detect do |adjustment|
          adjustment.source == self
        end
      end

      def build_adjustment(line_item)
        line_item.adjustments.build(
          order: line_item.order,
          source: self
        )
      end

      def find_item(order)
        order.line_items.detect { |line_item| line_item.managed_by_order_benefit == self }
      end

      def build_item(order)
        order.line_items.build(quantity: determine_item_quantity(order), variant: variant, managed_by_order_benefit: self)
      end

      def determine_item_quantity(order)
        # Integer division will floor automatically, which is what we want here:
        # 1 Item, 2 needed: 1 * 1 / 2 => 0
        # 5 items, 2 preferred, 2 needed: 5 / 2 * 2 => 4
        applicable_line_items(order).sum(&:quantity) / preferred_necessary_quantity * preferred_quantity
      end

      def set_quantity(line_item, quantity)
        line_item.quantity_setter = self
        line_item.quantity = quantity
      end

      def variant
        Spree::Variant.find(preferred_variant_id)
      end
    end
  end
end
