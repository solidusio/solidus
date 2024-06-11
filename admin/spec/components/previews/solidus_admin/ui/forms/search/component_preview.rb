# frozen_string_literal: true

# @component "ui/forms/search"
class SolidusAdmin::UI::Forms::Search::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
