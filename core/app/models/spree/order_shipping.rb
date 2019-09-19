# frozen_string_literal: true

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
  def ship_shipment(shipment, external_number: nil, tracking_number: nil, suppress_mailer: false)
    ship(
      inventory_units: shipment.inventory_units.shippable,
      stock_location: shipment.stock_location,
      address: shipment.order.ship_address,
      shipping_method: shipment.shipping_method,
      shipped_at: Time.current,
      external_number: external_number,
      # TODO: Remove the `|| shipment.tracking` once Shipment#ship! is called by
      # OrderShipping#ship rather than vice versa
      tracking_number: tracking_number || shipment.tracking,
      suppress_mailer: suppress_mailer
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
           shipped_at: Time.current, external_number: nil, tracking_number: nil, suppress_mailer: false)

    carton = nil

    Spree::InventoryUnit.transaction do
      inventory_units.each(&:ship!)

      carton = Spree::Carton.create!(
        stock_location: stock_location,
        address: address,
        shipping_method: shipping_method,
        inventory_units: inventory_units,
        shipped_at: shipped_at,
        external_number: external_number,
        tracking: tracking_number
      )
    end

    inventory_units.map(&:shipment).uniq.each do |shipment|
      # Temporarily propagate the tracking number to the shipment as well
      # TODO: Remove tracking numbers from shipments.
      shipment.update!(tracking: tracking_number)

      next unless shipment.inventory_units.reload.all? { |iu| iu.shipped? || iu.canceled? }
      # TODO: make OrderShipping#ship_shipment call Shipment#ship! rather than
      # having Shipment#ship! call OrderShipping#ship_shipment. We only really
      # need this `update_columns` for the specs, until we make that change.
      shipment.update_columns(state: 'shipped', shipped_at: Time.current)
    end

    send_shipment_emails(carton) if stock_location.fulfillable? && !suppress_mailer # e.g. digital gift cards that aren't actually shipped
    @order.recalculate

    carton
  end

  private

  def send_shipment_emails(carton)
    carton.orders.each do |order|
      Spree::Config.carton_shipped_email_class.shipped_email(order: order, carton: carton).deliver_later
    end
  end
end
