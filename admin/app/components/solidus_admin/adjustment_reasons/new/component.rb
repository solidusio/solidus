# frozen_string_literal: true

class SolidusAdmin::AdjustmentReasons::New::Component < SolidusAdmin::BaseComponent
  def initialize(adjustment_reason:)
    @adjustment_reason = adjustment_reason
  end

  def form_id
    dom_id(@adjustment_reason, "#{stimulus_id}_new_adjustment_reason_form")
  end
end
