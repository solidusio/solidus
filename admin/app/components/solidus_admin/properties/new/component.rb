# frozen_string_literal: true

class SolidusAdmin::Properties::New::Component < SolidusAdmin::BaseComponent
  def initialize(page:, property:)
    @page = page
    @property = property
  end

  def form_id
    dom_id(@property, "#{stimulus_id}_new_property_form")
  end
end
