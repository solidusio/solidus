# frozen_string_literal: true

require_relative 'event/adapters/active_support_notifications'
require_relative 'event/subscriber_registry'
require_relative 'event/configuration'
require_relative 'event/subscriber'

module Spree
  module Event
    extend self

    delegate :activate_autoloadable_subscribers, :activate_all_subscribers, :deactivate_all_subscribers, to: :subscriber_registry

    # Allows to trigger events that can be subscribed using #subscribe. An
    # optional block can be passed that will be executed immediately. The
    # actual code implementation is delegated to the adapter.
    #
    # @param [String] event_name the name of the event. The suffix ".spree"
    #  will be added automatically if not present
    # @param [Hash] opts a list of options to be passed to the triggered event
    #
    # @example Trigger an event named 'order_finalized'
    #   Spree::Event.fire 'order_finalized', order: @order do
    #     @order.finalize!
    #   end
    def fire(event_name, opts = {})
      adapter.fire normalize_name(event_name), opts do
        yield opts if block_given?
      end
    end

    # @deprecated Loads all Solidus' core and application's event subscribers files.
    # The latter are loaded automatically only when the preference
    # Spree::Config.events.autoload_subscribers is set to a truthy value.
    #
    # Files must be placed under the directory `app/subscribers` and their
    # name must end with `_subscriber.rb`.
    #
    # Loading the files has the side effect of adding their module to the
    # list in Spree::Event.subscribers.
    def require_subscriber_files
      Spree::Deprecation.warn("#{self}.require_subscriber_files is deprecated and will be removed in Solidus 3.0.", caller)
      subscriber_registry.send(:require_subscriber_files)
    end

    # Subscribe to an event with the given name. The provided block is executed
    # every time the subscribed event is fired.
    #
    # @param [String, Regexp] event_name the name of the event.
    #  When String, the suffix ".spree" will be added automatically if not present,
    #  when using the default adapter for ActiveSupportNotifications.
    #  When Regexp, due to the unpredictability of all possible regexp combinations,
    #  adding the suffix is developer's responsibility (if you don't, you will
    #  subscribe to all notifications, including internal Rails notifications
    #  as well).
    #
    # @see Spree::Event::Adapters::ActiveSupportNotifications#normalize_name
    #
    # @return a subscription object that can be used as reference in order
    #  to remove the subscription
    #
    # @example Subscribe to the `order_finalized` event
    #   Spree::Event.subscribe 'order_finalized' do |event|
    #     order = event.payload[:order]
    #     Spree::Mailer.order_finalized(order).deliver_later
    #   end
    #
    # @see Spree::Event#unsubscribe
    def subscribe(event_name, &block)
      name = normalize_name(event_name)
      listener_names << name
      adapter.subscribe(name, &block)
    end

    # Unsubscribes a whole event or a specific subscription object
    #
    # @param [String, Object] subscriber the event name as a string (with
    #  or without the ".spree" suffix) or the subscription object
    #
    # @example Unsubscribe a single subscription
    #   subscription = Spree::Event.fire 'order_finalized'
    #   Spree::Event.unsubscribe(subscription)
    # @example Unsubscribe all `order_finalized` event subscriptions
    #   Spree::Event.unsubscribe('order_finalized')
    # @example Unsubscribe an event by name with explicit prefix
    #   Spree::Event.unsubscribe('order_finalized.spree')
    def unsubscribe(subscriber)
      name_or_subscriber = subscriber.is_a?(String) ? normalize_name(subscriber) : subscriber
      adapter.unsubscribe(name_or_subscriber)
    end

    # Lists all subscriptions currently registered under the ".spree"
    # namespace. Actual implementation is delegated to the adapter
    #
    # @return [Hash] an hash with event names as keys and arrays of subscriptions
    #  as values
    #
    # @example Current subscriptions
    #  Spree::Event.listeners
    #    # => {"order_finalized.spree"=> [#<ActiveSupport...>],
    #      "reimbursement_reimbursed.spree"=> [#<ActiveSupport...>]}
    def listeners
      adapter.listeners_for(listener_names)
    end

    # The adapter used by Spree::Event, defaults to
    # Spree::Event::Adapters::ActiveSupportNotifications
    #
    # @example Change the adapter
    #   Spree::Config.events.adapter = "Spree::EventBus.new"
    #
    # @see Spree::AppConfiguration
    def adapter
      Spree::Config.events.adapter
    end

    # The suffix used for namespacing Solidus events, defaults to
    # `.spree`
    #
    # @see Spree::Event::Configuration#suffix
    def suffix
      Spree::Deprecation.warn "This method is deprecated and will be removed. Please use Event::Adapters::ActiveSupportNotifications#suffix"
      Spree::Config.events.suffix
    end

    # @deprecated
    # @!attribute [r] subscribers
    #   @return [Array<Spree::Event::Subscriber>] A list of subscribers used to support class reloading for Spree::Event::Subscriber instances
    def subscribers
      Spree::Deprecation.warn("`#{self}.subscribers` is deprecated. Please use `#{self}.subscriber_registry` instead.", caller)
      Spree::Config.events.subscribers
    end

    # @!attribute [r] subscribers
    #   @return <Spree::Event::SubscriberRegistry> The registry for supporting class reloading for Spree::Event::Subscriber instances
    def subscriber_registry
      Spree::Config.events.subscriber_registry
    end

    private

    def normalize_name(name)
     adapter.normalize_name(name)
    end

    def listener_names
      @listeners_names ||= Set.new
    end
  end
end
