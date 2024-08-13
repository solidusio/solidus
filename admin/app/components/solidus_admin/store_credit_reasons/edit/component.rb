# frozen_string_literal: true

class SolidusAdmin::StoreCreditReasons::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(page:, store_credit_reason:)
    @page = page
    @store_credit_reason = store_credit_reason
  end

  def form_id
    dom_id(@store_credit_reason, "#{stimulus_id}_edit_store_credit_reason_form")
  end
end
