# frozen_string_literal: true

# @component "ui/checkbox_row"
class SolidusAdmin::UI::CheckboxRow::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
