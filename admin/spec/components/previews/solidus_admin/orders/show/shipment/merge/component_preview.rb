# frozen_string_literal: true

# @component "orders/show/shipment/merge"
class SolidusAdmin::Orders::Show::Shipment::Merge::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param shipment text
  def playground(shipment: "shipment")
    render component("orders/show/shipment/merge").new(shipment: shipment)
  end
end
