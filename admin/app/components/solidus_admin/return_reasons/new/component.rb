# frozen_string_literal: true

class SolidusAdmin::ReturnReasons::New::Component < SolidusAdmin::BaseComponent
  def initialize(return_reason:)
    @return_reason = return_reason
  end

  def form_id
    dom_id(@return_reason, "#{stimulus_id}_new_return_reason_form")
  end
end
