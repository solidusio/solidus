# frozen_string_literal: true

module Spree
  module Event
    # A triggered event
    #
    # An instance of it is automatically created on {Spree::Event.fire}.  The
    # instance is consumed on {Spree::Event.subscribe}.
    #
    # @example
    #   Spree::Event.fire 'event_name', foo: 'bar'
    #   Spree::Event.subscribe 'event_name' do |event|
    #     puts event.payload['foo'] #=> 'bar'
    #   end
    class Event
      # Hash with the options given to {Spree::Event.fire}
      #
      # @return [Hash]
      attr_reader :payload

      # @api private
      def initialize(payload:)
        @payload = payload
      end
    end
  end
end
