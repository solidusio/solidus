# frozen_string_literal: true

module Spree
  module Event
    module Adapters
      module ActiveSupportNotifications
        class InvalidEventNameType < StandardError; end

        extend self

        def fire(event_name, opts)
          ActiveSupport::Notifications.instrument event_name, opts do
            yield opts if block_given?
          end
        end

        def subscribe(event_name)
          ActiveSupport::Notifications.subscribe event_name do |*args|
            event = ActiveSupport::Notifications::Event.new(*args)
            yield event
          end
        end

        def unsubscribe(subscriber_or_name)
          ActiveSupport::Notifications.unsubscribe(subscriber_or_name)
        end

        def listeners_for(names)
          names.each_with_object({}) do |name, memo|
            listeners = ActiveSupport::Notifications.notifier.listeners_for(name)
            memo[name] = listeners if listeners.present?
          end
        end

        # Normalizes the event name according to this specific adapter rules.
        #  When the event name is a string or a symbol, if the suffix is missing, then
        #  it is added automatically.
        #  When the event name is a regexp, due to the huge variability of regexps, adding
        #  or not the suffix is developer's responsibility (if you don't, you will subscribe
        #  to all internal rails events as well).
        #  When the event type is not supported, an error is raised.
        #
        # @param [String, Symbol, Regexp] event_name the event name, with or without the
        #  suffix (Spree::Config.events.suffix defaults to `.spree`).
        def normalize_name(event_name)
          case event_name
          when Regexp
            event_name
          when String, Symbol
            name = event_name.to_s
            name.end_with?(suffix) ? name : [name, suffix].join
          else
            raise InvalidEventNameType, "Invalid event name type: #{event_name.class}"
          end
        end

        # The suffix used for namespacing event names, defaults to
        # `.spree`
        #
        # @see Spree::Event::Configuration#suffix
        def suffix
          Spree::Config.events.suffix
        end
      end
    end
  end
end
