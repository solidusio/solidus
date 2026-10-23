# frozen_string_literal: true

class SolidusAdmin::Products::New::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  include SolidusAdmin::Products::FormOptions

  def initialize(product:)
    @product = product
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-new"
  end
end
