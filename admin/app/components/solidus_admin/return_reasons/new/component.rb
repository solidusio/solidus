# frozen_string_literal: true

class SolidusAdmin::ReturnReasons::New::Component < SolidusAdmin::BaseComponent
  def initialize(page:, return_reason:)
    @page = page
    @return_reason = return_reason
  end

  def form_id
    dom_id(@return_reason, "#{stimulus_id}_new_return_reason_form")
  end
end
