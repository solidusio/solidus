# frozen_string_literal: true

# @component "orders/show/shipment/split"
class SolidusAdmin::Orders::Show::Shipment::Split::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param shipment text
  def playground(shipment: "shipment")
    render component("orders/show/shipment/split").new(shipment: shipment)
  end
end
