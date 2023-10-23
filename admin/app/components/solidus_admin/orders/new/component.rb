# frozen_string_literal: true

class SolidusAdmin::Orders::New::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(order:)
    @order = order
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@order.id}"
  end
end
