# frozen_string_literal: true

require 'spree/event'

module Spree
  module Event
    # Test helpers for {Spree::Event}
    #
    # This module defines test helpers methods for {Spree::Event}. They can be
    # made available to {Spree::Event} when {Spree::Event.enable_test_interface}
    # is called.
    #
    # If you prefer, you can directly call them from
    # `Spree::Event::TestInterface}.
    module TestInterface
      # @see {Spree::Event::TestInterface}
      module Methods
        # Perform only given listeners for the duration of the block
        #
        # Temporarily deactivate all subscribed listeners and listen only to the
        # provided ones for the duration of the block.
        #
        # @example
        #   Spree::Event.enable_test_interface
        #
        #   listener1 = Spree::Event.subscribe('foo') { do_something }
        #   listener2 = Spree::Event.subscribe('foo') { do_something_else }
        #
        #   Spree::Event.performing_only(listener1) do
        #     Spree::Event.fire('foo') # This will run only `listener1`
        #   end
        #
        #   Spree::Event.fire('foo') # This will run both `listener1` & `listener2`
        #
        # {Spree::Event::Subscriber} modules can also be given to unsubscribe from
        # all listeners generated from it:
        #
        # @example
        #   Spree::Event.performing_only(EmailSubscriber) {}
        #
        # You can gain more fine-grained control thanks to
        # {Spree::Event::Subscribe#listeners}:
        #
        # @example
        #   Spree::Event.performing_only(EmailSubscriber.listeners('order_finalized')) {}
        #
        # You can mix different ways of specifying listeners without problems:
        #
        # @example
        #   Spree::Event.performing_only(EmailSubscriber, listener1) {}
        #
        # @param listeners_and_subscribers [Spree::Event::Listener,
        # Array<Spree::Event::Listener>, Spree::Event::Subscriber]
        # @yield While the block executes only provided listeners will run
        def performing_only(*listeners_and_subscribers)
          adapter_in_use = Spree::Event.default_adapter
          listeners = listeners_and_subscribers.flatten.map(&:listeners)
          Spree::Config.events.adapter = adapter_in_use.with_listeners(listeners.flatten)
          yield
        ensure
          Spree::Config.events.adapter = adapter_in_use
        end

        # Perform no listeners for the duration of the block
        #
        # It's a specialized version of {#performing_only} that provides no
        # listeners.
        #
        # @yield While the block executes no listeners will run
        #
        # @see Spree::Event::TestInterface#performing_only
        def performing_nothing(&block)
          performing_only(&block)
        end
      end

      extend Methods
    end

    # Adds test methods to {Spree::Event}
    #
    # @raise [RuntimeError] when {Spree::Event::Configuration#adapter} is set to
    # the legacy adapter {Spree::Event::Adapters::ActiveSupportNotifications}.
    def enable_test_interface
      raise <<~MSG if deprecation_handler.legacy_adapter?(default_adapter)
        Spree::Event's test interface is not supported when using the deprecated
        adapter 'Spree::Event::Adapters::ActiveSupportNotifications'.
      MSG

      extend(TestInterface::Methods)
    end
  end
end
