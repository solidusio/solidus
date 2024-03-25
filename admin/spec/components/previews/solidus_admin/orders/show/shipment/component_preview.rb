# frozen_string_literal: true

# @component "orders/show/shipment"
class SolidusAdmin::Orders::Show::Shipment::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param shipment text
  def playground(shipment: "shipment")
    render component("orders/show/shipment").new(shipment: shipment)
  end
end
