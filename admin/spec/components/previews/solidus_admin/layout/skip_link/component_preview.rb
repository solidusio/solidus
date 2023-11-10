# frozen_string_literal: true

# @component "layout/skip_link"
class SolidusAdmin::Layout::SkipLink::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # Click on the "Preview" window area and press "Tab" to see the skip link
  def overview
    render current_component.new(href: "#")
  end
end
