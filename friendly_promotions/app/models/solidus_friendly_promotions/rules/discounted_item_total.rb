# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    # A rule to apply to an order greater than (or greater than or equal to)
    # a specific amount after previous promotions have applied
    #
    # To add extra operators please override `self.operators_map` or any other helper method.
    # To customize the error message you can also override `ineligible_message`.
    class DiscountedItemTotal < ItemTotal
      def to_partial_path
        "solidus_friendly_promotions/admin/conditions/rules/item_total"
      end

      private

      def total_for_order(order)
        order.discountable_item_total
      end
    end
  end
end
