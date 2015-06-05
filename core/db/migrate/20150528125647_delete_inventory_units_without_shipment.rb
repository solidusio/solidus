class DeleteInventoryUnitsWithoutShipment < ActiveRecord::Migration
  # Prevent everything from running in one giant transaction in postrgres.
  disable_ddl_transaction!

  def up
    order_ids = Spree::InventoryUnit.where(shipment_id: nil).pluck(:order_id).uniq.compact
    Spree::Order.where(id: order_ids).find_each do |order|
      # Order may not be completed but have shipped
      # shipments if it has a pending unreturned exchange
      next if order.completed?
      next if order.canceled?
      next if order.shipments.any? { |s| s.shipped? || s.ready? || s.canceled? }
      say "Removing inventory units without shipment for order ##{order.number}"
      order.transaction do
        order.inventory_units.destroy_all
        order.shipments.destroy_all
        order.restart_checkout_flow
      end
    end
  end

  def down
    # intentionally left blank
  end
end
