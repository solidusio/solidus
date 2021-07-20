# frozen_string_literal: true

module Spree
  module Event
    module Adapters
      # Deprecated adapter for the event bus system.
      #
      # Please, upgrade to {Spree::Event::Adapters::Default}.
      #
      # This adapter normalizes the event name so that it includes
      # {Spree::Event::Configuration#suffix}.
      # When the event name is a string or a symbol, if the suffix is missing,
      # then it is added automatically. When the event name is a regexp, due
      # to the huge variability of regexps, adding or not the suffix is
      # developer's responsibility (if you don't, you will subscribe to all
      # internal rails events as well).  When the event type is not supported,
      # an error is raised.
      #
      # The suffix can be changed through `config.events.suffix=` in `spree.rb`.
      module ActiveSupportNotifications
        class InvalidEventNameType < StandardError; end

        extend self

        # @api private
        def fire(event_name, opts)
          ActiveSupport::Notifications.instrument normalize_name(event_name), opts do
            yield opts if block_given?
          end
        end

        # @api private
        def subscribe(event_name)
          ActiveSupport::Notifications.subscribe normalize_name(event_name) do |*args|
            event = ActiveSupport::Notifications::Event.new(*args)
            yield event
          end
        end

        # @api private
        def unsubscribe(subscriber_or_name)
          subscriber_or_name = subscriber_or_name.is_a?(String) ? normalize_name(subscriber_or_name) : subscriber_or_name
          ActiveSupport::Notifications.unsubscribe(subscriber_or_name)
        end

        # @api private
        def listeners_for(names)
          names.each_with_object({}) do |name, memo|
            listeners = ActiveSupport::Notifications.notifier.listeners_for(name)
            memo[name] = listeners if listeners.present?
          end
        end

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

        # @api private
        def suffix
          Spree::Config.events.suffix
        end
      end
    end
  end
end
