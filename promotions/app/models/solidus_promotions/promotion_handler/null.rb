# frozen_string_literal: true

module SolidusPromotions
  module PromotionHandler
    # We handle shipping promotions just like other promotions, so we don't need a
    # special promotion handler for shipping. However, Solidus wants us to implement one.
    # This is what this class is for.
    class Null
      attr_reader :order
      attr_accessor :error, :success

      def initialize(order)
        @order = order
      end

      def activate
      end
    end
  end
end
