module Solidus::Admin::StoreCreditEventsHelper
  mattr_accessor :originator_links
  self.originator_links = {
    Solidus::Payment.to_s => {
      new_tab: true,
      href_type: :payment,
      translation_key: 'admin.store_credits.payment_originator'
    },
    Solidus::Refund.to_s => {
      new_tab: true,
      href_type: :payments,
      translation_key: 'admin.store_credits.refund_originator'
    },
  }

  def store_credit_event_admin_action_name(store_credit_event)
    if Solidus::StoreCreditEvent::NON_EXPOSED_ACTIONS.include?(store_credit_event.action) ||
      store_credit_event.action == Solidus::StoreCredit::VOID_ACTION
      Solidus.t("store_credit.display_action.admin.#{store_credit_event.action}")
    else
      store_credit_event.display_action
    end
  end

  def store_credit_event_originator_link(store_credit_event)
    originator = store_credit_event.originator
    return unless originator

    add_user_originator_link
    unless self.originator_links.key?(store_credit_event.originator.class.to_s)
      raise "Unexpected originator type #{originator.class.to_s}"
    end

    options = {}
    link_options = self.originator_links[store_credit_event.originator.class.to_s]
    options[:target] = '_blank' if link_options[:new_tab]

    # Although not all href_types are used in originator_links
    # they are necessary because they may be used within extensions
    case link_options[:href_type]
    when :user
      link_to(
        Solidus.t(link_options[:translation_key], { email: originator.email }),
        solidus.edit_admin_user_path(originator),
        options
      )
    when :line_item
      order = originator.line_item.order
      link_to(
        Solidus.t(link_options[:translation_key], { order_number: order.number }),
        solidus.edit_admin_order_path(order),
        options
      )
    when :payment
      order = originator.order
      link_to(
        Solidus.t(link_options[:translation_key], { order_number: order.number }),
        solidus.admin_order_payment_path(order, originator),
        options
      )
    when :payments
      order = originator.payment.order
      link_to(
        Solidus.t(link_options[:translation_key], { order_number: order.number }),
        solidus.admin_order_payments_path(order),
        options
      )
    end
  end

  private

  # Cannot set the value for a user originator
  # because Solidus.user_class is not defined at that time.
  # Solidus::UserClassHandle does not work here either as
  # the assignment is evaluated before user_class is set
  def add_user_originator_link
    self.originator_links[Solidus.user_class.to_s] = {
      new_tab: true,
      href_type: :user,
      translation_key: 'admin.store_credits.user_originator'
    }
  end
end
