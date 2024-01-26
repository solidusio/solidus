# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Rules
      class FirstRepeatPurchaseSince < PromotionRule
        preference :days_ago, :integer, default: 365
        validates :preferred_days_ago, numericality: { only_integer: true, greater_than: 0 }

        # This promotion is applicable to orders only.
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        # This is never eligible if the order does not have a user, and that user does not have any previous completed orders.
        #
        # This is eligible if the user's most recently completed order is more than the preferred days ago
        # @param order [Spree::Order]
        def eligible?(order, _options = {})
          return false unless order.user

          last_order = last_completed_order(order.user)
          return false unless last_order

          last_order.completed_at < preferred_days_ago.days.ago
        end

        private

        def last_completed_order(user)
          user.orders.complete.order(:completed_at).last
        end
      end
    end
  end
end
