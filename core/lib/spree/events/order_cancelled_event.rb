# frozen_string_literal: true

module Spree
  module Events
    class OrderCancelledEvent
      attr_reader :order_id

      def initialize(order_id:)
        @order_id = order_id
      end
    end
  end
end
