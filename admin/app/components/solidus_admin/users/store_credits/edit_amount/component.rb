# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::EditAmount::Component < SolidusAdmin::BaseComponent
  def initialize(user:, store_credit:, events:, reasons:)
    @user = user
    @store_credit = store_credit
    @store_credit_events = events
    @store_credit_reasons = reasons
  end

  def form_id
    dom_id(@store_credit, "#{stimulus_id}_edit_amount_form")
  end

  def store_credit_reasons_select_options
    # Placeholder + Store Credit Reasons
    "<option value>#{t('.choose_reason')}</option>" + options_from_collection_for_select(@store_credit_reasons, :id, :name)
  end
end
