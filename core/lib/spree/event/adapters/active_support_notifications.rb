# frozen_string_literal: true

module Spree
  module Event
    module Adapters
      module ActiveSupportNotifications
        extend self

        def instrument(event_name, opts)
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

        def unsubscribe(subscriber)
          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
      end
    end
  end
end
