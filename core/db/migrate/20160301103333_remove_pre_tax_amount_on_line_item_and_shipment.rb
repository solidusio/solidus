class RemovePreTaxAmountOnLineItemAndShipment < ActiveRecord::Migration
  def change
    remove_column :spree_line_items, :pre_tax_amount, :decimal, precision: 12, scale: 4, default: 0.0, null: false
    remove_column :spree_shipments, :pre_tax_amount, :decimal, precision: 12, scale: 4, default: 0.0, null: false
  end
end
