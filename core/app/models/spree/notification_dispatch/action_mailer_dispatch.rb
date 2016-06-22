# Default sender class for Spree::NotificationDispatch, sends via
# ActionMailer.
#
# You can see the mapping from notification message types to
# ActionMailer classes and methods in `.mailer_dispatch_table`, which
# you can also customize to map to different mailers or methods.
#
# The particular argument list for each message type is
# specified in NotificationDispatch.signatures
class Spree::NotificationDispatch::ActionMailerDispatch
  class_attribute :mailer_dispatch_table
  # values are pairs of fully qualified mailer class names, and method names
  self.mailer_dispatch_table = {
    carton_shipped: ['Spree::CartonMailer', :shipped_email],
    order_confirm: ['Spree::OrderMailer', :confirm_email],
    order_cancel: ['Spree::OrderMailer', :cancel_email],
    order_inventory_cancel: ['Spree::OrderMailer', :inventory_cancellation_email],
    reimbursement_processed: ['Spree::ReimbursementMailer', :reimbursement_email]
  }

  attr_reader :message

  def initialize(init_message)
    @message = init_message.to_sym
    unless mailer_dispatch_table.key?(message)
      raise ArgumentError.new("Spree::NotificationDisaptcher::ActionMailerDispatch: no dispatch found for message `#{message}`. Do you need to configure `#{self.class.name}.dispatch_table`?")
    end
  end

  def deliver(*args)
    action_mail_object(*args).deliver_later
  end

  # Returns an ActionMailer::MessageDelivery, the thing you call #deliver_later
  # on, can be used in mailer preview actions.
  def action_mail_object(*args)
    action_mailer, method = lookup_dispatch
    action_mailer.send(method, *args)
  end

  def lookup_dispatch
    mailer_class_name, mailer_method = mailer_dispatch_table[message]

    mailer_class = if message == :carton_shipped &&
                      Spree::Config.carton_shipped_email_class &&
                      Spree::Config.carton_shipped_email_class.name != mailer_class_name
                    Spree::Deprecation.warn(":carton_shipped_email_class on Spree::Config is deprecated, please customize the #{self.class.name}.dispatch_table instead.")
                    Spree::Config.carton_shipped_email_class
                  else
                    mailer_class_name.constantize
                  end

    [mailer_class, mailer_method]
  end
end
