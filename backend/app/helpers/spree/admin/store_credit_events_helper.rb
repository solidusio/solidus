module Spree::Admin::StoreCreditEventsHelper
  def store_credit_event_admin_action_name(store_credit_event)
    if Spree::StoreCreditEvent::NON_EXPOSED_ACTIONS.include?(store_credit_event.action) ||
       store_credit_event.action == Spree::StoreCredit::VOID_ACTION
      Spree.t("store_credit.display_action.admin.#{store_credit_event.action}")
    else
      store_credit_event.display_action
    end
  end
end
