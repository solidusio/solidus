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
    #
    # Besides, it can be accessed through the returned value in {Spree::Event.fire}.
    # It can be useful for debugging and logging purposes, as it contains
    # helpful metadata like the event time or the caller location.
    class Event
      # Hash with the options given to {Spree::Event.fire}
      #
      # @return [Hash]
      attr_reader :payload

      # Time of the event firing
      #
      # @return [Time]
      attr_reader :firing_time

      # Location for the event caller
      #
      # It's usually set by {Spree::Event.fire}, and it points to the caller of
      # that method.
      #
      # @return [Thread::Backtrace::Location]
      attr_reader :caller_location

      # @api private
      def initialize(payload:, caller_location:, firing_time: Time.now.utc)
        @payload = payload
        @caller_location = caller_location
        @firing_time = firing_time
      end
    end
  end
end
