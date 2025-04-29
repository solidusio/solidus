# frozen_string_literal: true

# @component "ui/toast"
class SolidusAdmin::UI::Alert::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
