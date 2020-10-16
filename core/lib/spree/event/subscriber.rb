# frozen_string_literal: true

module Spree
  module Event
    # This module simplifies adding and removing subscriptions to {Spree::Event} events.
    # Here's a complete example:
    #   module EmailSender
    #     include Spree::Event::Subscriber
    #
    #     event_action :order_finalized
    #     event_action :confirm_reimbursement, event_name: :reimbursement_reimbursed
    #
    #     def order_finalized(event)
    #       Mailer.send_email(event.payload[:order])
    #     end
    #
    #     def confirm_reimbursement(event)
    #       Mailer.send_email(event.payload[:reimbursement])
    #     end
    #   end
    #
    #  # Optional, required only when the subscriber needs to be loaded manually.
    #  #
    #  # If Spree::Config.events.autoload_subscribers is set to `true` and the module
    #  # file matches the pattern `app/subscribers/**/*_subscriber.rb` then it will
    #  # be loaded automatically at boot and this line can be removed:
    #  EmailSender.activate
    module Subscriber
      def self.included(base)
        base.extend base

        base.mattr_accessor :event_actions
        base.event_actions = {}

        Spree::Event.subscriber_registry.register(base)
      end

      # Declares a method name in the including module that can be subscribed/unsubscribed
      # to an event.
      #
      # @param method_name [String, Symbol] the method that will be called when the subscribed event is fired
      # @param event_name [String, Symbol] the name of the event to be subscribed
      #
      # @example Declares 'send_email' as an event action that can subscribe the event 'order_finalized'
      #   module EmailSender
      #     event_action :send_email, event_name: :order_finalized
      #
      #     def send_email(event)
      #       Mailer.send_email(event.payload[:order])
      #     end
      #   end
      #
      # @example Same as above, but the method name is same as the event name:
      #   module EmailSender
      #     event_action :order_completed
      #
      #     def order_completed(event)
      #       Mailer.send_email(event.payload[:order])
      #     end
      #   end
      def event_action(method_name, event_name: nil)
        mattr_writer "#{method_name}_handler"

        define_method "#{method_name}_handler" do
          Spree::Deprecation.warn("#{name}.#{method_name}_handler and #{name}.#{method_name}_handler= from the old events mapping interface are deprecated. Please use the new mapping stored in Spree::Event.subscribers.", caller)

          class_variable_get("@@#{method_name}_handler")
        end

        event_actions[method_name] = (event_name || method_name).to_s
      end

      # Activates all declared event actions to their events. Only actions that are activated
      # will be called when their event fires.
      #
      # @example activate all event actions for module 'EmailSender'
      #    EmailSender.activate
      def activate
        Spree::Event.subscriber_registry.activate_subscriber(self)
      end

      # Deactivates all declared event actions (or a single specific one) from their events.
      # This means that when an event fires then none of its unsubscribed event actions will
      # be called.
      # @example deactivate all event actions for module 'EmailSender'
      #    EmailSender.deactivate
      # @example deactivate only order_finalized for module 'EmailSender'
      #    EmailSender.deactivate(:order_finalized)
      def deactivate(event_action_name = nil)
        Spree::Event.subscriber_registry.deactivate_subscriber(self, event_action_name)
      end

      def subscribe!
        Spree::Deprecation.warn("#{self}.subscribe! is deprecated. Please use `#{self}.activate`.", caller)
        activate
      end

      def unsubscribe!
        Spree::Deprecation.warn("#{self}.unsubscribe! is deprecated. Please use `#{self}.deactivate`.", caller)
        deactivate
      end
    end
  end
end
