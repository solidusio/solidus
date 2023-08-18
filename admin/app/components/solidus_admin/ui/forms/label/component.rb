# frozen_string_literal: true

# @api private
class SolidusAdmin::UI::Forms::Label::Component < SolidusAdmin::BaseComponent
  def initialize(field:, form:)
    @field = field
    @form = form
  end

  def call
    @form.label(@field, class: "block mb-0.5 body-tiny-bold")
  end
end
