# frozen_string_literal: true

require "spree/bus"

module Spree
  module TestingSupport
    # RSpec test helpers for the event bus
    #
    # If you want to use the methods defined in this module, include it in your
    # specs:
    #
    # @example
    #   require 'rails_helper'
    #   require 'spree/testing_support/bus_helpers'
    #
    #   RSpec.describe MyClass do
    #     include Spree::TestingSupport::BusHelpers
    #   end
    #
    # or, globally, in your `spec_helper.rb`:
    #
    # @example
    #   require 'spree/testing_support/bus_helpers'
    #
    #   RSpec.configure do |config|
    #     config.include Spree::TestingSupport::BusHelpers
    #   end
    module BusHelpers
      extend RSpec::Matchers::DSL

      # Stubs {Spree::Bus}
      #
      # After you have called this method in an example, {Spree::Bus} will no
      # longer publish any event for the duration of that example. All the
      # method invocations on it will be stubbed.
      #
      # Internally, it stubs {Spree::Bus#publish}.
      #
      # After you call this method, probably you'll want to call some of the
      # matchers defined in this module.
      def stub_spree_bus
        allow(Spree::Bus).to receive(:publish)
      end

      # @!method have_been_published(event_name)
      #   Matcher to test that an event has been published via {Spree::Bus#publish}
      #
      #   Before using this matcher, you need to call {#stub_spree_bus}.
      #
      #   Remember that the event listeners won't be performed.
      #
      #   @example
      #     it 'publishes foo event' do
      #       stub_spree_bus
      #
      #       Spree::Bus.publish 'foo'
      #
      #       expect('foo').to have_been_published
      #     end
      #
      #   It can be chain through `with` to match with the published payload:
      #
      #   @example
      #     it 'publishes foo event with the expected payload' do
      #       stub_spree_bus
      #
      #       Spree::Bus.publish 'foo', bar: :baz, qux: :quux
      #
      #       expect('foo').to have_been_published.with(a_hash_including(bar: :baz))
      #     end
      #
      #   @param [Symbol] event_name
      matcher :have_been_published do
        chain :with, :payload

        match do |expected_event|
          expected_event = normalize_name(expected_event)
          arguments = payload ? [expected_event, payload] : [expected_event, any_args]
          expect(Spree::Bus).to have_received(:publish).with(*arguments)
        end

        failure_message do |expected_event|
          <<~MSG
            expected #{expected_event.inspect} to have been published.
            Make sure that provided payload, if any, also matches.
          MSG
        end

        def normalize_name(event_name)
          if event_name.is_a?(Symbol)
            eq(event_name)
          else
            raise ArgumentError, <<~MSG
              "#{event_name.inspect} is not a valid event name. It must be a Symbol."
            MSG
          end
        end
      end
    end
  end
end
