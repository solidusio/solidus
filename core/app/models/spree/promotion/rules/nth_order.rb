# frozen_string_literal: true

module Spree
  class Promotion
    module Rules
      class NthOrder < PromotionRule
        preference :nth_order, :integer, default: 2
        # It does not make sense to have this apply to the first order using preferred_nth_order == 1
        # Instead we could use the first_order rule
        validates :preferred_nth_order, numericality: { only_integer: true, greater_than: 1 }

        # This promotion is applicable to orders only.
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        # This is never eligible if the order does not have a user, and that user does not have any previous completed orders.
        #
        # Use the first order rule if you want a promotion to be applied to the first order for a user.
        # @param order [Spree::Order]
        def eligible?(order, _options = {})
          return false unless order.user

          nth_order?(order)
        end

        private

        def completed_order_count(order)
          order.
            user.
            orders.
            complete.
            where(Spree::Order.arel_table[:completed_at].lt(order.completed_at || Time.current)).
            count
        end

        def nth_order?(order)
          count = completed_order_count(order) + 1
          count == preferred_nth_order
        end
      end
    end
  end
end
