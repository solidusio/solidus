# frozen_string_literal: true

module Spree
  module TestingSupport
    module EventHelpers
      def self.fired_events
        @fired_events ||= []
      end

      def perform_subscribers(only: nil, except: nil)
        if only && except
          raise ArgumentError, <<~ERROR.strip
            You cannot pass both `:only` and `:except` to `perform_subscribers`!
          ERROR
        end

        _with_subscriber_registry_override do
          Spree::Event.deactivate_all_subscribers

          registry = Spree::Config.events.subscriber_registry

          if only # perform_subscribers(only: [Subscriber1, Subscriber2]) { ... }
            Array(only).each { |subscriber| registry.activate_subscriber(subscriber) }
          elsif except # perform_subscribers(except: [Subscriber1, Subscriber2]) { ... }
            registry.activate_all_subscribers
            Array(except).each { |subscriber| registry.deactivate_subscriber(subscriber) }
          else # perform_subscribers { ... }
            registry.activate_all_subscribers
          end

          yield
        end
      end

      private

      def _deactivate_all_subscribers
        registry = Spree::Config.events.subscriber_registry

        registry.send(:registry).each_key do |subscriber_name|
          if (subscriber_const = subscriber_name.safe_constantize)
            registry.deactivate_subscriber(subscriber_const)
          else
            registry.send(:registry).delete(subscriber_name)
          end
        end
      end

      def _with_subscriber_registry_override
        registry = Spree::Config.events.subscriber_registry

        active_subscribers = registry.send(:registry).select do |_, actions|
          actions.any?
        end.keys

        yield
      ensure
        _deactivate_all_subscribers

        active_subscribers.each do |subscriber|
          registry.activate_subscriber(subscriber.constantize)
        end
      end

      module Matchers
        extend RSpec::Matchers::DSL

        matcher :have_been_fired do
          match do |expected_event|
            Spree::TestingSupport::EventHelpers.fired_events.any? do |fired_event|
              values_match?(fired_event.name, Spree::Config.events.adapter.normalize_name(expected_event)) &&
                (@expected_payload.nil? || values_match?(@expected_payload, fired_event.payload))
            end
          end

          chain :with do |expected_payload|
            @expected_payload = expected_payload
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Spree::TestingSupport::EventHelpers
  config.include Spree::TestingSupport::EventHelpers::Matchers

  config.before(:all) do
    Spree::Event.subscribe(/.*#{Regexp.escape(Spree::Config.events.suffix)}$/) do |event|
      Spree::TestingSupport::EventHelpers.fired_events << event
    end
  end

  config.before do
    Spree::TestingSupport::EventHelpers.fired_events.clear
    _deactivate_all_subscribers
  end
end
