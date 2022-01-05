# frozen_string_literal: true

require 'spree/event/adapters/deprecation_handler'
require 'spree/event/adapters/active_support_notifications'

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

      # TODO: Update to Adapters::Default.new on Solidus 4
      def adapter
        @adapter ||= Adapters::ActiveSupportNotifications.tap do |adapter|
          Spree::Deprecation.warn <<~MSG if Adapters::DeprecationHandler.render_deprecation_message?(adapter)
            `Spree::Event::Adapters::ActiveSupportNotifications` adapter is
            deprecated. Please, take your time to update it to an instance of
            `Spree::Event::Adapters::Default`. I.e., in your `spree.rb`:

            require 'spree/event/adapters/default'

            Spree.config do |config|
              # ...
              config.events.adapter = Spree::Event::Adapters::Default.new
              # ...
            end

            That will be the new default on Solidus 4.

            Take into account there're three critical changes in behavior in the new adapter:

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

          - You need to register your custom events before firing or subscribing
            to them (not necessary for events provided by Solidus or other
            extensions). It should be done at the end of the `spree.rb`
            initializer. Example:

              Spree::Event.register('foo')
              Spree::Event.fire('foo')


          MSG
        end
      end

      # Only used by {Spree::Event::Adapters::ActiveSupportNotifications}.
      def suffix
        @suffix ||= '.spree'
      end
    end
  end
end
