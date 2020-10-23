# frozen_string_literal: true

module Spree
  module Event
    class Configuration
      def subscriber_registry
        @subscriber_registry ||= Spree::Event::SubscriberRegistry.new
      end

      def subscribers
        Spree::Deprecation.warn("`Spree::Config.events.subscribers` is deprecated. Please use `Spree::Config.events.subscriber_registry`.", caller)
        subscriber_registry.send(:registry).keys.map { |module_name| module_name.constantize }
      end

      attr_writer :adapter, :suffix, :autoload_subscribers

      def autoload_subscribers
        @autoload_subscribers.nil? ? true : !!@autoload_subscribers
      end

      def adapter
        @adapter ||= Spree::Event::Adapters::ActiveSupportNotifications
      end

      def suffix
        @suffix ||= '.spree'
      end
    end
  end
end
