# frozen_string_literal: true

class SolidusAdmin::AdjustmentReasons::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(page:, adjustment_reason:)
    @page = page
    @adjustment_reason = adjustment_reason
  end

  def form_id
    dom_id(@adjustment_reason, "#{stimulus_id}_edit_adjustment_reason_form")
  end

  def close_path
    solidus_admin.adjustment_reasons_path(**search_filter_params)
  end
end
