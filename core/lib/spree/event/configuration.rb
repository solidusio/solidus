# frozen_string_literal: true

module Spree
  module Event
    class Configuration
      def subscriber_registry
        @subscriber_registry ||= Spree::Event::SubscriberRegistry.new
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

