# frozen_string_literal: true

# @component "orders/show/shipment/edit"
class SolidusAdmin::Orders::Show::Shipment::Edit::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param shipment text
  def playground(shipment: "shipment")
    render component("orders/show/shipment/edit").new(shipment: shipment)
  end
end
