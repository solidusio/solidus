class AddPromoTotalToLineItemsAndShipmentsAndOrders < ActiveRecord::Migration
  def change
    add_column :solidus_line_items, :promo_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :solidus_shipments, :promo_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :solidus_orders, :promo_total, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
