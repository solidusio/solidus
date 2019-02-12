# frozen_string_literal: true

module Spree
  module Event
    class Configuration
      attr_writer :adapter

      def adapter
        @adapter ||= Spree::Event::Adapters::ActiveSupportNotifications
      end
    end
  end
end
