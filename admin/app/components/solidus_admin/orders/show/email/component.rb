# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Email::Component < SolidusAdmin::BaseComponent
  def initialize(order:)
    @order = order
  end

  def form_id
    dom_id(@order, "#{stimulus_id}_email_form")
  end
end
