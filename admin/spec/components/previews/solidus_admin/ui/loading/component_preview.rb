# frozen_string_literal: true

# @component "ui/loading"
class SolidusAdmin::UI::Loading::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
