# frozen_string_literal: true

require 'spree/event/event'
require 'spree/event/listener'
require 'spree/event/firing'
require 'spree/event/registry'

module Spree
  module Event
    module Adapters
      # Adapter for {Spree::Event}
      #
      # Please, access it through {Spree::Event} module. You only need to
      # configure an instance of it to be used as the default adapter.  E.g., in
      # `spree.rb` initializer:
      #
      # @example
      #   require "spree/event/adapters/default"
      #
      #   Spree.config do |config|
      #     # ...
      #     config.events.adapter = Spree::Event::Adapters::Default.new
      #     # ...
      #   end
      #
      # You won't need to do that from Solidus version 4.0 as this adapter will
      # be the default one.
      class Default
        # @api private
        attr_reader :listeners, :registry

        def initialize(listeners = [], registry = Registry.new)
          @listeners = listeners
          @registry = registry
        end

        # @api private
        def register(event_name, caller_location: caller_locations(1)[0])
          registry.register(event_name, caller_location: caller_location)
        end

        # @api private
        def fire(event_name, caller_location: caller_locations(1)[0], **payload)
          registry.check_event_name_registered(event_name)
          event = Event.new(payload: payload, caller_location: caller_location)
          executions = listeners_for_event(event_name).map do |listener|
            listener.call(event)
          end
          Firing.new(event: event, executions: executions)
        end

        # @api private
        def subscribe(event_name_or_regexp, &block)
          registry.check_event_name_registered(event_name_or_regexp) if event_name?(event_name_or_regexp)
          Listener.new(pattern: event_name_or_regexp, block: block).tap do |listener|
            @listeners << listener
          end
        end

        # @api private
        def unsubscribe(subscriber_or_event_name)
          if subscriber_or_event_name.is_a?(Listener)
            unsubscribe_listener(subscriber_or_event_name)
          else
            registry.check_event_name_registered(subscriber_or_event_name) if event_name?(subscriber_or_event_name)
            unsubscribe_event(subscriber_or_event_name)
          end
        end

        # @api private
        def with_listeners(listeners)
          self.class.new(listeners, registry)
        end

        private

        def listeners_for_event(event_name)
          @listeners.select do |listener|
            listener.matches?(event_name)
          end
        end

        def unsubscribe_listener(listener)
          @listeners.delete(listener)
        end

        def unsubscribe_event(event_name)
          @listeners.each do |listener|
            listener.unsubscribe(event_name)
          end
        end

        def event_name?(candidate)
          candidate.is_a?(String)
        end
      end
    end
  end
end
