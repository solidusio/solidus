# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Shipment::Merge::Component < SolidusAdmin::BaseComponent
  def initialize(shipment:)
    @shipment = shipment
  end
end
