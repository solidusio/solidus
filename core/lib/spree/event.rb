# frozen_string_literal: true

require_relative 'event/adapters/deprecation_handler'
require_relative 'event/configuration'
require_relative 'event/listener'
require_relative 'event/subscriber_registry'
require_relative 'event/subscriber'
require 'spree/deprecation'

module Spree
  # Event bus for Solidus.
  #
  # This module serves as the interface to access the Event Bus system in
  # Solidus. You can use different underlying adapters to provide the core
  # logic. It's recommended that you use {Spree::Event::Adapters::Default}.
  #
  # Before firing, subscribing, or unsubscribing an event, you need to
  # {#register} it:
  #
  # @example
  #   Spree::Event.register 'order_finalized'
  #
  # You use the {#fire} method to trigger an event:
  #
  #  @example
  #    Spree::Event.fire 'order_finalized', order: order
  #
  # Then, you can use {#subscribe} to hook into the event:
  #
  #   @example
  #     Spree::Event.subscribe 'order_finalized' do |event|
  #       # Take the order at event.payload[:order]
  #     end
  #
  # You can also subscribe to an event through a module including
  # {Spree::Event::Subscriber}:
  #
  #  @example
  #    module MySubscriber
  #      include Spree::Event::Subscriber
  #
  #      event_action :order_finalized
  #
  #      def order_finalized(event)
  #        # Again, take the order at event.payload[:order]
  #      end
  #    end
  module Event
    extend self

    delegate :activate_autoloadable_subscribers, :activate_all_subscribers, :deactivate_all_subscribers, to: :subscriber_registry

    # Registers an event
    #
    # This step is needed before firing, subscribing or unsubscribing an
    # event. It helps to prevent typos and naming collision.
    #
    # This method is not available in the legacy adapter.
    #
    # @example
    #   Spree::Event.register('foo')
    #
    # @param [String, Symbol] event_name
    # @param [Any] adapter the event bus adapter to use.
    def register(event_name, adapter: default_adapter)
      warn_registration_on_legacy_adapter if deprecation_handler.render_deprecation_message?(adapter)
      return if deprecation_handler.legacy_adapter?(adapter)

      adapter.register(normalize_name(event_name), caller_location: caller_locations(1)[0])
    end

    # @api private
    def registry(adapter: default_adapter)
      warn_registration_on_legacy_adapter if deprecation_handler.render_deprecation_message?(adapter)
      return if deprecation_handler.legacy_adapter?(adapter)

      adapter.registry
    end

    # Allows to trigger events that can be subscribed using {#subscribe}.
    #
    # The actual code implementation is delegated to the adapter.
    #
    # @param [String, Symbol] event_name the name of the event.
    # @param [Hash] opts a list of options to be passed to the triggered event.
    # They will be made available through the {Spree::Event::Event} instance
    # that is yielded to the subscribers (see {Spree::Event::Event#payload}).
    # However, take into account that the deprecated
    # {Spree::Event::Adapters::ActiveSupportNotifications} adapter will yield a
    # {ActiveSupport::Notifications::Fanout::Subscribers::Timed} instance
    # instead.
    # @option opts [Any] :adapter Reserved to indicate the adapter to use as
    # event bus. Defaults to {#default_adapter}
    # @return [Spree::Event::Firing] A firing object encapsulating metadata for
    # the event and the originated listener executions, unless the adapter is
    # {Spree::Event::Adapters::ActiveSupportNotifications}
    #
    # @example Trigger an event named 'order_finalized'
    #   Spree::Event.fire 'order_finalized', order: @order do
    #     @order.complete!
    #   end
    #
    # TODO: Change signature so that `opts` are keyword arguments, and include
    # `adapter:` in them. We want to do that on Solidus 4.0. Spree::Deprecation
    # can't be used because of this: https://github.com/solidusio/solidus/pull/4130#discussion_r668666924
    def fire(event_name, opts = {}, &block)
      adapter = opts.delete(:adapter) || default_adapter
      handle_block_on_fire(block, opts, adapter) if block_given?
      if deprecation_handler.legacy_adapter?(adapter)
        adapter.fire(normalize_name(event_name), opts)
      else
        adapter.fire(normalize_name(event_name), caller_location: caller_locations(1)[0], **opts)
      end
    end

    # Subscribe to events matching the given name.
    #
    # The provided block is executed every time the subscribed event is fired.
    #
    # @param [String, Symbol, Regexp] event_name the name of the event. When it's a
    # {Regexp} it subscribes to all that match.
    # @param [Any] adapter the event bus adapter to use.
    # @yield block to execute when an event is triggered
    #
    # @return [Spree::Event::Listener] a subscription object that can be used as
    # reference in order to remove the subscription. However, take into account
    # that the deprecated {Spree::Event::Adapters::ActiveSupportNotifications}
    # adapter will return a
    # {ActiveSupport::Notifications::Fanout::Subscribers::Timed} instance
    # instead.
    #
    # @example Subscribe to the `order_finalized` event
    #   Spree::Event.subscribe 'order_finalized' do |event|
    #     order = event.payload[:order]
    #     Spree::Mailer.order_finalized(order).deliver_later
    #   end
    #
    # @see Spree::Event#unsubscribe
    def subscribe(event_name, adapter: default_adapter, &block)
      event_name = normalize_name(event_name)
      adapter.subscribe(event_name, &block).tap do
        if deprecation_handler.legacy_adapter?(adapter)
          listener_names << adapter.normalize_name(event_name)
        end
      end
    end

    # Unsubscribes a whole event or a specific subscription object
    #
    # When unsubscribing from an event, all previous listeners are deactivated.
    # Still, you can add new subscriptions to the same event and they'll be
    # called if the event is fired:
    #
    # @example
    #   Spree::Event.subscribe('foo') { do_something }
    #   Spree::Event.unsubscribe 'foo'
    #   Spree::Event.subscribe('foo') { do_something_else }
    #   Spree::Event.fire 'foo' # `do_something_else` will be called, but
    #   # `do_something` won't
    #
    # @param [String, Symbol, Spree::Event::Listener] subscriber_or_event_name the
    # event name as a string or the subscription object. Take into account that
    # if the deprecated {Spree::Event::Adapters::ActiveSupportNotifications}
    # adapter is used, the subscription object will be a
    # {ActiveSupport::Notifications::Fanout::Subscribers::Timed} object.
    #
    # @example Unsubscribe a single subscription
    #   subscription = Spree::Event.subscribe('order_finalized') { do_something
    #   }
    #   Spree::Event.unsubscribe(subscription)
    # @example Unsubscribe all `order_finalized` event subscriptions
    #   Spree::Event.unsubscribe('order_finalized')
    def unsubscribe(subscriber_or_event_name, adapter: default_adapter)
      if subscriber_or_event_name.is_a?(Listener) || subscriber_or_event_name.is_a?(ActiveSupport::Notifications::Fanout::Subscribers::Timed)
        unsubscribe_listener(subscriber_or_event_name, adapter)
      else
        unsubscribe_event(subscriber_or_event_name, adapter)
      end
    end

    # Lists all subscriptions.
    #
    # Actual implementation is delegated to the adapter.
    #
    # @return [Hash<<String,Regexp>,Spree::Event::Listener>] an hash with
    # patterns as keys and arrays of subscriptions as values. Take into account
    # that the deprecated {Spree::Event::Adapters::ActiveSupportNotifications}
    # adapter will map to
    # {ActiveSupport::Notifications::Fanout::Subscribers::Timed} instances
    # instead.
    #
    # @example Current subscriptions
    #  Spree::Event.listeners
    #    # => {"order_finalized"=> [#<Spree::Event::Listener...>],
    #         "reimbursement_reimbursed"=> [#<Spree::Event::Listener...>]}
    def listeners(adapter: default_adapter)
      if deprecation_handler.legacy_adapter?(adapter)
        adapter.listeners_for(listener_names)
      else
        init = Hash.new { |h, k| h[k] = [] }
        adapter.listeners.each_with_object(init) do |listener, map|
          map[listener.pattern] << listener
        end
      end
    end

    # The default adapter used by Spree::Event.
    #
    # @example Change the adapter
    #   Spree::Config.events.adapter = "Spree::OtherAdapter.new"
    #
    # @see Spree::Event::Configuration
    def default_adapter
      Spree::Config.events.adapter
    end

    def adapter
      Spree::Deprecation.warn <<~MSG
        `Spree::Event.adapter` is deprecated. Please, use
        `Spree::Event.default_adapter` instead.
      MSG
      default_adapter
    end

    # @!attribute [r] subscribers
    #   @return <Spree::Event::SubscriberRegistry> The registry for supporting class reloading for Spree::Event::Subscriber instances
    def subscriber_registry
      Spree::Config.events.subscriber_registry
    end

    private

    def unsubscribe_listener(listener, adapter)
      adapter.unsubscribe(listener)
    end

    def unsubscribe_event(event_name, adapter)
      adapter.unsubscribe(normalize_name(event_name))
    end

    def listener_names
      @listeners_names ||= Set.new
    end

    def normalize_name(name)
      case name
      when Symbol
        name.to_s
      else
        name
      end
    end

    def handle_block_on_fire(block, opts, adapter)
      example = <<~MSG
        Please, instead of:

          Spree::Event.fire 'event_name', order: order do
            order.do_something
          end

        Use:

          order.do_something
          Spree::Event.fire 'event_name', order: order
      MSG
      if deprecation_handler.legacy_adapter?(adapter)
        Spree::Deprecation.warn <<~MSG if deprecation_handler.render_deprecation_message?(adapter)
          Blocks on `Spree::Event.fire` are ignored in the new adapter
          `Spree::Event::Adapters::Default`, and your current adapter
          (`Spree::Event::Adapters::ActiveSupportNotifications`) is deprecated.
          For an easier transition it's recommendable to update your code.

          #{example}

        MSG
        block.call(opts)
      else
        raise ArgumentError, <<~MSG
          Blocks passed to `Spree::Event.fire` are ignored unless the adapter is
          `Spree::Event::Adapters::ActiveSupportNotifications` (which is
          deprecated).

          #{example}

        MSG
      end
    end

    def warn_registration_on_legacy_adapter
      Spree::Deprecation.warn <<~MSG
        Event registration works only on the new adapter
        `Spree::Event::Adapters::Default`. Please, update to it.
      MSG
    end

    def deprecation_handler
      Adapters::DeprecationHandler
    end
  end
end
