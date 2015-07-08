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

    case originator
    when Spree::User
      translation_key = 'user'
      translation_options = { email: originator.email }
      href = spree.edit_admin_user_path(originator)
    when Spree::Payment
      order = originator.order
      translation_key = 'payment'
      translation_options = { order_number: order.number }
      href = spree.admin_order_payment_path(order, originator)
    when Spree::Refund
      order = originator.payment.order
      translation_key = 'refund'
      translation_options = { order_number: order.number }
      href = spree.admin_order_payments_path(order)
    when Spree::VirtualGiftCard
      order = originator.line_item.order
      translation_key = 'giftcard'
      translation_options = { order_number: order.number }
      href = spree.edit_admin_order_path(order)
    else
      raise "Unexpected originator type #{originator.class.to_s}"
    end

    link_to(
      Spree.t("admin.store_credits.#{translation_key}_originator", translation_options),
      href,
      target: '_blank'
    )
  end
end
