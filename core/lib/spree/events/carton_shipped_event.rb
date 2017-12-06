# frozen_string_literal: true

module Spree
  module Events
    class CartonShippedEvent
      attr_reader :carton_id

      def initialize(carton_id:)
        @carton_id = carton_id
      end
    end
  end
end
