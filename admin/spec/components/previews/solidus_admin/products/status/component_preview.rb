# frozen_string_literal: true

# @component "products/status"
class SolidusAdmin::Products::Status::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template(locals:
      {
        definitions: {
          available: available_component,
          discontinued: discontinued_component
        }
      })
  end

  private

  def available_component
    current_component.new(
      product: Spree::Product.new(available_on: Time.current)
    )
  end

  def discontinued_component
    current_component.new(
      product: Spree::Product.new(available_on: nil)
    )
  end
end
