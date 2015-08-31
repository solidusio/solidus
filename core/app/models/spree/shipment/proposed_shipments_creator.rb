class Spree::Shipment::ProposedShipmentsCreator
  attr_reader :order, :original_shipping_methods

  class CannotRebuildShipments < StandardError; end

  class_attribute :shipping_method_handler
  # Customization hook to allow stores to manipulate
  # the generated shipments' shipping method
  self.shipping_method_handler = ->(proposed_shipments, original_shipping_methods) { }

  def initialize(order)
    @order = order
    @original_shipping_methods = order.shipments.map(&:shipping_method).compact.uniq
  end

  def shipments
    if order.completed?
      raise CannotRebuildShipments.new(Spree.t(:cannot_rebuild_shipments_order_completed))
    elsif order.shipments.any? { |s| !s.pending? }
      raise CannotRebuildShipments.new(Spree.t(:cannot_rebuild_shipments_shipments_not_pending))
    else
      order.adjustments.shipping.destroy_all
      order.shipments.destroy_all
      proposed_shipments = Spree::Stock::Coordinator.new(order).shipments
      self.shipping_method_handler.call(proposed_shipments, original_shipping_methods)
      proposed_shipments
    end
  end
end
