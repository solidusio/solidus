# frozen_string_literal: true

require 'spree/core/class_constantizer'

module Spree
  module Event
    class Configuration
      def subscribers
        @subscribers ||= ::Spree::Core::ClassConstantizer::Set.new
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
