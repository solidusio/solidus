# A service layer that handles generating Carton objects when inventory units
# are actually shipped.  It also takes care of things like updating order and
# shipment states and delivering shipment emails as needed.
class Spree::OrderShipping
  def initialize(order)
    @order = order
  end

  # A shortcut method that ships *all* inventory units in a shipment in a single
  # carton.  See also {#ship}.
  #
  # @param shipment The shipment to create a carton from.
  # @param external_number An optional external number. e.g. from a shipping company or 3PL.
  # @param tracking_number An optional tracking number.
  # @return The carton created.
  def ship_shipment(shipment, external_number: nil, tracking_number: nil)
    ship(
      inventory_units: shipment.inventory_units.pre_shipment,
      stock_location: shipment.stock_location,
      address: shipment.address,
      shipping_method: shipment.shipping_method,
      shipped_at: Time.now,
      external_number: external_number,
      # TODO: Remove the `|| shipment.tracking` once Shipment#ship! is called by
      # OrderShipping#ship rather than vice versa
      tracking_number: tracking_number || shipment.tracking,
    )
  end

  # Generate a carton from the supplied inventory units and marks those units
  # as shipped.  Also sends shipment emails if appropriate and updates
  # shipment_states for associated orders.
  #
  # @param inventory_units The units to put in a carton together.
  # @param stock_location The location the carton shipped from.
  # @param address The address the carton was shipped to.
  # @param shipping_method Shipping method used for the carton.
  # @param shipped_at The time at which the shipment was shipped.
  # @param external_number An optional external number. e.g. from a shipping company or 3PL.
  # @param tracking_number An option tracking number.
  # @return The carton created.
  def ship(inventory_units:, stock_location:, address:, shipping_method:,
           shipped_at: Time.now, external_number: nil, tracking_number: nil)

    carton = nil

    Spree::InventoryUnit.transaction do
      inventory_units.each &:ship!

      carton = Spree::Carton.create!(
        stock_location: stock_location,
        address: address,
        shipping_method: shipping_method,
        inventory_units: inventory_units,
        shipped_at: shipped_at,
        external_number: external_number,
        tracking: tracking_number,
      )
    end

    inventory_units.map(&:shipment).uniq.each do |shipment|
      # Temporarily propagate the tracking number to the shipment as well
      # TODO: Remove tracking numbers from shipments.
      shipment.update_attributes!(tracking: tracking_number)

      if shipment.inventory_units.all?(&:shipped?)
        # TODO: make OrderShipping#ship_shipment call Shipment#ship! rather than
        # having Shipment#ship! call OrderShipping#ship_shipment. We only really
        # need this `update_columns` for the specs, until we make that change.
        shipment.update_columns(state: 'shipped', shipped_at: Time.now)
      end
    end

    send_shipment_email(carton) if stock_location.fulfillable? # e.g. digital gift cards that aren't actually shipped
    fulfill_order_stock_locations(stock_location)
    update_order_state

    carton
  end

  private

  def fulfill_order_stock_locations(stock_location)
    Spree::OrderStockLocation.fulfill_for_order_with_stock_location(@order, stock_location)
  end

  def update_order_state
    new_state = Spree::OrderUpdater.new(@order).update_shipment_state
    @order.update_columns(
      shipment_state: new_state,
      updated_at: Time.now,
    )
  end

  def send_shipment_email(carton)
    Spree::CartonMailer.shipped_email(carton.id).deliver
  end
end
