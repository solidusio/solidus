module Spree::Admin::StoreCreditEventsHelper
  def store_credit_event_admin_action_name(store_credit_event)
    if Spree::StoreCreditEvent::NON_EXPOSED_ACTIONS.include?(store_credit_event.action) ||
      store_credit_event.action == Spree::StoreCredit::VOID_ACTION
      Spree.t("store_credit.display_action.admin.#{store_credit_event.action}")
    else
      store_credit_event.display_action
    end
  end

  def store_credit_event_originator_link(store_credit_event)
    originator = store_credit_event.originator
    return unless originator

    options = { target: '_blank' }
    case originator
    when Spree.user_class
      link_to(
        Spree.t("admin.store_credits.user_originator", { email: originator.email }),
        spree.edit_admin_user_path(originator),
        options
      )
    when Spree::Payment
      order = originator.order
      link_to(
        Spree.t("admin.store_credits.payment_originator", { order_number: order.number }),
        spree.admin_order_payment_path(order, originator),
        options
      )
    when Spree::Refund
      order = originator.payment.order
      link_to(
        Spree.t("admin.store_credits.refund_originator", { order_number: order.number }),
        spree.admin_order_payments_path(order),
        options
      )
    when Spree::VirtualGiftCard
      order = originator.line_item.order
      link_to(
        Spree.t("admin.store_credits.giftcard_originator", { order_number: order.number }),
        spree.edit_admin_order_path(order),
        options
      )
    else
      raise "Unexpected originator type #{originator.class.to_s}"
    end
  end
end
