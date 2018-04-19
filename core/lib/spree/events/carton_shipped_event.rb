# frozen_string_literal: true

module Spree
  module Events
    class CartonShippedEvent
      attr_reader :carton_id, :suppress_customer_notification

      def initialize(carton_id:, suppress_customer_notification: false)
        @carton_id = carton_id
        @suppress_customer_notification = suppress_customer_notification
      end
    end
  end
end
