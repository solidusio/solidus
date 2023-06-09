# frozen_string_literal: true

module Spree
  class UnitCancel < Spree::Base
    # This class encapsulates what the system needs to do in order to recalculate
    # adjustments originating from Unit Cancels.
    class OrderCancellationsRecalculator
      def initialize(order)
        @order = order
      end

      def call
        line_items.each do |line_item|
          line_item.adjustments.select(&:cancellation?).each { |cancellation| recalculate(cancellation) }
        end
      end

      private
      attr_reader :order
      delegate :line_items, to: :order

      # Recalculate and persist the amount from this cancellation's source based on
      # the adjustable ({LineItem})
      #
      # @return [BigDecimal] New amount of this adjustment
      def recalculate(cancellation)
        if cancellation.finalized?
          return cancellation.amount
        end

        cancellation.amount = cancellation.source.compute_amount(cancellation.adjustable)

        # Persist only if changed
        # This is only not a save! to avoid the extra queries to load the order
        # (for validations) and to touch the cancellation.
        cancellation.update_columns(amount: cancellation.amount, updated_at: Time.current) if cancellation.changed?
        cancellation.amount
      end
    end
  end
end
