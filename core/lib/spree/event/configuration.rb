# frozen_string_literal: true

module Spree
  module Event
    class Configuration
      attr_writer :adapter, :suffix

      def adapter
        @adapter ||= Spree::Event::Adapters::ActiveSupportNotifications
      end

      def suffix
        @suffix ||= '.spree'
      end
    end
  end
end
