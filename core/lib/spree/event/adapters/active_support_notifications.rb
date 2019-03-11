# frozen_string_literal: true

module Spree
  module Event
    module Adapters
      module ActiveSupportNotifications
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
      end
    end
  end
end
