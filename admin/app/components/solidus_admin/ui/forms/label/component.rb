# frozen_string_literal: true

# @api private
class SolidusAdmin::UI::Forms::Label::Component < SolidusAdmin::BaseComponent
  def initialize(field:, builder:)
    @field = field
    @builder = builder
  end

  def call
    @builder.label(@field, class: "block mb-0.5 body-tiny-bold")
  end
end
