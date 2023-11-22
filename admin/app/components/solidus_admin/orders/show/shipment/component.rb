# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Shipment::Component < SolidusAdmin::BaseComponent
  def initialize(shipment:, index:)
    @shipment = shipment
    @index = index
  end

  def manifest
    Spree::ShippingManifest.new(
      inventory_units: @shipment.inventory_units.where(carton_id: nil),
    ).items.sort_by { |item| item.line_item.created_at }
  end
end
