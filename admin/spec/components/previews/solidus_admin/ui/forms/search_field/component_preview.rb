# frozen_string_literal: true

# @component "ui/forms/search_field"
class SolidusAdmin::UI::Forms::SearchField::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
