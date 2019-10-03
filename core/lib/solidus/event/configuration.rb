# frozen_string_literal: true

require 'solidus/core/class_constantizer'

module Solidus
  module Event
    class Configuration
      def subscribers
        @subscribers ||= ::Solidus::Core::ClassConstantizer::Set.new.tap do |set|
          set << 'Solidus::MailerSubscriber'
        end
      end

      attr_writer :adapter, :suffix

      def adapter
        @adapter ||= Solidus::Event::Adapters::ActiveSupportNotifications
      end

      def suffix
        @suffix ||= '.spree'
      end
    end
  end
end
