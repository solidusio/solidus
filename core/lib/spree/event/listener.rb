# frozen_string_literal: true

require 'benchmark'
require 'spree/event/execution'

module Spree
  module Event
    # Subscription to an event
    #
    # An instance of it is returned on {Spree::Event.subscribe}.
    #
    # You're not expected to perform any action with it, besides using it as
    # a reference to unsubscribe.
    #
    # @example
    #   listener = Spree::Event.subscribe 'event_name'
    #   Spree::Event.unsubscribe listener
    class Listener
      # @api private
      attr_reader :pattern, :block

      # @api private
      def initialize(pattern:, block:)
        @pattern = pattern
        @block = block
        @exclusions = []
      end

      # @api private
      def call(event)
        result = nil
        benchmark = Benchmark.measure do
          result = @block.call(event)
        end

        Execution.new(listener: self, result: result, benchmark: benchmark)
      end

      # @api private
      def matches?(event_name)
        pattern === event_name &&
          !excludes?(event_name)
      end

      # @api private
      def unsubscribe(event_name)
        return unless matches?(event_name)

        @exclusions << event_name
      end

      private

      def excludes?(event_name)
        @exclusions.include?(event_name)
      end
    end
  end
end
