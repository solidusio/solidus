# frozen_string_literal: true

class SolidusAdmin::StoreCreditReasons::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(page:, store_credit_reason:)
    @page = page
    @store_credit_reason = store_credit_reason
  end

  def form_id
    dom_id(@store_credit_reason, "#{stimulus_id}_edit_store_credit_reason_form")
  end

  def close_path
    solidus_admin.store_credit_reasons_path(**search_filter_params)
  end
end
