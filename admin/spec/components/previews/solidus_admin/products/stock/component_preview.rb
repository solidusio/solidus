# frozen_string_literal: true

# @component "products/stock"
class SolidusAdmin::Products::Stock::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end
end
