# frozen_string_literal: true

require_relative 'event/adapters/active_support_notifications'

module Spree
  module Event
    POSTFIX = '.spree'

    extend self

    mattr_accessor(:adapter) { Spree::Event::Adapters::ActiveSupportNotifications }

    def publish(event_name, opts = {})
      adapter.instrument name_with_postfix(event_name), opts do
        yield opts if block_given?
      end
    end

    def subscribe(event_name, &block)
      name = name_with_postfix(event_name)
      listener_names << name
      adapter.subscribe(name, &block)
    end

    def unsubscribe(subscriber)
      name_or_subscriber = subscriber.is_a?(String) ? name_with_postfix(subscriber) : subscriber
      adapter.unsubscribe(name_or_subscriber)
    end

    def listeners
      adapter.listeners_for(listener_names)
    end

    private

    def name_with_postfix(name)
      name.end_with?(POSTFIX) ? name : [name, POSTFIX].join
    end

    def listener_names
      @listeners_names ||= Set.new
    end
  end
end
