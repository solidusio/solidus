# frozen_string_literal: true

require 'spree/core/versioned_value'
require 'spree/event/adapters/active_support_notifications'
require 'spree/event/adapters/default'

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
        @adapter ||= Spree::Core::VersionedValue.new(
          Spree::Event::Adapters::ActiveSupportNotifications,
          "4.0.0.alpha" => Spree::Event::Adapters::Default.new
        ).call.tap do |value|
          deprecate_if_legacy_adapter(value)
        end
      end

      # Only used by {Spree::Event::Adapters::ActiveSupportNotifications}.
      def suffix
        @suffix ||= '.spree'
      end

      private

      def deprecate_if_legacy_adapter(adapter)
        Spree::Deprecation.warn <<~MSG if adapter == Spree::Event::Adapters::ActiveSupportNotifications
          `Spree::Event::Adapters::ActiveSupportNotifications` adapter is
          deprecated. Please, take your time to update it to an instance of
          `Spree::Event::Adapters::Default`. I.e., in your `spree.rb`:

          require 'spree/event/adapters/default'

          Spree.config do |config|
            # ...
            config.events.adapter = Spree::Event::Adapters.Default.new
            # ...
          end

          That will be the new default on Solidus 4.

          Take into account there're two critical changes in behavior in the new adapter:

          - Event names are no longer automatically suffixed with `.spree`, as
          they're no longer in the same bucket that Rails's ones. So, for
          instance, if you were relying on a global subscription to all Solidus
          events with:

            Spree::Event.subscribe /.*\.spree$/

          You should change it to:

            Spree::Event.subscribe /.*/

          - Providing a block to `Spree::Event.fire` is no longer supported. If
          you're doing something like:

            Spree::Event.fire 'event_name', order: order do
              order.do_something
            end

            You now need to change it to:

            order.do_something
            Spree::Event.fire 'event_name', order: order

        MSG
      end
    end
  end
end
