# frozen_string_literal: true

# @component "products/status"
class SolidusAdmin::Products::Status::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
