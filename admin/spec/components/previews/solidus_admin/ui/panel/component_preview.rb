# frozen_string_literal: true

# @component "ui/panel"
class SolidusAdmin::UI::Panel::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
