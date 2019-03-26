# frozen_string_literal: true

module Spree
  module Event
    module Subscriber
      def self.included(base)
        base.extend base

        base.mattr_accessor :event_actions
        base.event_actions = {}
      end

      def event_action(method_name, event_name: nil)
        mattr_accessor "#{method_name}_handler"
        event_actions[method_name] = (event_name || method_name).to_s
      end

      def subscribe!
        unsubscribe!
        event_actions.each do |event_action, event_name|
          send "#{event_action}_handler=", Spree::Event.subscribe(event_name) { |event|
            send event_action, event
          }
        end
      end

      def unsubscribe!
        event_actions.keys.each do |event_action|
          Spree::Event.unsubscribe send("#{event_action}_handler")
        end
      end
    end
  end
end
