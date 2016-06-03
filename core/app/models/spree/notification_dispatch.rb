module Spree
  # This class is responsible for sending 'transactional' emails to users,
  # carton shipped, order confirmed, etc.
  #
  # By default it uses the NotificationDispatch::ActionMailerDispatcher to
  # send emails with ActionMailer. You can change the actual delivery method
  # by changing `Spree::NotificationDispatch.delivery_class_name` to the name
  # of a custom class, that sends email with a different API, or even sends
  # messages by means other than email.
  #
  # The sender class should have the same API as the NotificationDispatch:
  #
  #    SenderClass.new(message_type_symbol).deliver(messsage, arg1, arg2)
  #
  # To add a new notification message, edit NotificationDispatch.signatures
  # to add the signature, and if using the ActionMailerDispatcher, edit
  # mailer_dispatch_table there so it knows how to handle it.
  #
  # All messages will be suppressed if Spree::Config[:send_core_emails] is false.
  # additionally you can send only certain messages with eg:
  #
  #     Spree::NotificationDispatch.only_messages = [:order_confirm, :carton_shipped]
  #
  # or
  #
  #     Spree::NotificationDispatch.except_messages = [:reimbursement_processed]
  class NotificationDispatch
    # These serve as the specififications of what arguments go with what
    # notification messages, and are checked at runtime.
    class_attribute :signatures
    # the lambda bodies could be non-empty and check actual types if we want.
    self.signatures = {
      # should be (carton:, order:, resend: false), but currently supporting
      # deprecated options.
      carton_shipped: lambda { |options, deprecated_options = {}| },
      order_confirm: lambda { |order, resend = false| },
      order_cancel: lambda { |order, resend = false| },
      order_inventory_cancel: lambda { |order, inventory_units, resend = false| },
      reimbursement_processed: lambda { |reimbursement, resend = false| }
    }

    class_attribute :delivery_class_name
    # The actual class that does the delivery, by default one that uses ActionMailer.
    # This class simply needs to have a public API like NotificationDispatch itself:
    #      sender_class.new(message).deliver(*args)
    self.delivery_class_name = "Spree::NotificationDispatch::ActionMailerDispatch"

    class_attribute :only_messages
    class_attribute :except_messages

    attr_reader :message

    def initialize(message)
      @message = message.to_sym
      unless signatures.key? message
        raise ArgumentError.new("Unrecognized message `#{message}`. Do you need to add a message to `#{self.class.name}.signatures`?")
      end
    end

    def deliver(*args)
      if should_send?
        self.class.check_args(message, args)
        delivery_class.new(message).deliver(*args)
      end
    end

    def should_send?
      Spree::Config[:send_core_emails] &&
        (only_messages.nil? || only_messages.include?(message)) &&
        (except_messages.nil? || except_messages.exclude?(message))
    end

    def delivery_class
      delivery_class_name.constantize
    end

    def self.check_args(message, args)
      signatures[message].call(*args)
    end
  end
end
