# frozen_string_literal: true

module Spree
  module Event
    extend self

    def publish(event_name, opts = {}, &block)
      ActiveSupport::Notifications.instrument "spree.#{event_name}", opts, &block
    end

    def subscribe(event_name)
      ActiveSupport::Notifications.subscribe "spree.#{event_name}" do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        yield event
      end
    end

    def unsubscribe(subscriber)
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end
end
