# frozen_string_literal: true

# @component "ui/search_panel"
class SolidusAdmin::UI::SearchPanel::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
