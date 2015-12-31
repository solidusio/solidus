class AddTaxTotalToLineItemsShipmentsAndOrders < ActiveRecord::Migration
  def change
    add_column :solidus_line_items, :tax_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :solidus_shipments, :tax_total, :decimal, precision: 10, scale: 2, default: 0.0
    # This column may already be here from a 2.1.x migration
    add_column :solidus_orders, :tax_total, :decimal, precision: 10, scale: 2, default: 0.0 unless Solidus::Order.column_names.include?("tax_total")
  end
end
