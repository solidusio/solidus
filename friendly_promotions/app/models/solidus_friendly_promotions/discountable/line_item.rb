# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Discountable
    class LineItem < SimpleDelegator
      attr_reader :discounts, :order

      def initialize(line_item, order:)
        super(line_item)
        @order = order
        @discounts = []
      end

      def line_item
        __getobj__
      end

      def discounted_amount
        amount + discounts.sum(&:amount)
      end
    end
  end
end
