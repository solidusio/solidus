# frozen_string_literal: true

module Spree
  module Event
    extend self

    def publish(event_name, opts = {}, &block)
      ActiveSupport::Notifications.instrument "#{event_name}.spree", opts, &block
    end

    def subscribe(event_name)
      ActiveSupport::Notifications.subscribe "#{event_name}.spree" do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        yield event
      end
    end

    def unsubscribe(subscriber)
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end
end
