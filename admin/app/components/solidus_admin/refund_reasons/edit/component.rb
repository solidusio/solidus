# frozen_string_literal: true

class SolidusAdmin::RefundReasons::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(page:, refund_reason:)
    @page = page
    @refund_reason = refund_reason
  end

  def form_id
    dom_id(@refund_reason, "#{stimulus_id}_edit_refund_reason_form")
  end

  def close_path
    solidus_admin.refund_reasons_path(**search_filter_params)
  end
end
