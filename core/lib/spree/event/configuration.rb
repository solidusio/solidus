# frozen_string_literal: true

require 'spree/core/class_constantizer'

module Spree
  module Event
    class Configuration
      def subscribers
        @subscribers ||= ::Spree::Core::ClassConstantizer::Set.new.tap do |set|
          set << 'Spree::MailerSubscriber'
        end
      end

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
