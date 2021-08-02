# frozen_string_literal: true

require 'spree/event'

module Spree
  module TestingSupport
    # RSpec test helpers for the event bus
    #
    # If you want to use the methods defined in this module, include it in your
    # specs:
    #
    # @example
    #   require 'rails_helper'
    #   require 'spree/testing_support/event_helpers'
    #
    #   RSpec.describe MyClass do
    #     include Spree::TestingSupport::EventHelpers
    #   end
    #
    # or, globally, in your `spec_helper.rb`:
    #
    # @example
    #   require 'spree/testing_support/event_helpers'
    #
    #   RSpec.configure do |config|
    #     config.include Spree::TestingSupport::EventHelpers
    #   end
    module EventHelpers
      extend RSpec::Matchers::DSL

      # Stubs {Spree::Event}
      #
      # After you have called this method in an example, {Spree::Event} will no
      # longer listen to any event for the duration of that example. All the
      # method invocations on it will be spied but not performed.
      #
      # Internally, it stubs {Spree::Event} to a class spy of itself.
      #
      # After you call this method, probably you'll want to call some of the
      # matchers defined in this module.
      def stub_spree_events
        stub_const('Spree::Event', class_spy(Spree::Event))
      end

      # @!method have_been_fired(event_name)
      #   Matcher to test that an event has been fired via {Spree::Event#fire}
      #
      #   Before using this matcher, you need to call {#stub_spree_events}.
      #
      #   Remember that the event listeners won't be performed.
      #
      #   @example
      #     it 'fires foo event' do
      #       stub_spree_events
      #
      #       Spree::Event.fire 'foo'
      #
      #       expect('foo').to have_been_fired
      #     end
      #
      #   It can be chain through `with` to match with the published payload:
      #
      #   @example
      #     it 'fires foo event with the expected payload' do
      #       stub_spree_events
      #
      #       Spree::Event.fire 'foo', bar: :baz, qux: :quux
      #
      #       expect('foo').to have_been_fired.with(a_hash_including(bar: :baz))
      #     end
      #
      #   @param [String, Symbol] event_name
      matcher :have_been_fired do
        chain :with, :payload

        match do |expected_event|
          expected_event = normalize_name(expected_event)
          arguments = payload ? [expected_event, payload] : [expected_event, any_args]
          expect(Spree::Event).to have_received(:fire).with(*arguments)
        end

        failure_message do |expected_event|
          <<~MSG
            expected #{expected_event.inspect} to have been fired.
            Make sure that provided payload, if any, also matches.
          MSG
        end

        def normalize_name(event_name)
          if event_name.is_a?(String)
            eq(event_name).or(eq(event_name.to_sym))
          elsif event_name.is_a?(Symbol)
            eq(event_name).or(eq(event_name.to_s))
          else
            raise ArgumentError, <<~MSG
              "#{event_name.inspect} is not a valid event name. It must be a String or a Symbol."
            MSG
          end
        end
      end
    end
  end
end
