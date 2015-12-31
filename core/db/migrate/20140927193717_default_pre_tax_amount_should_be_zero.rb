class DefaultPreTaxAmountShouldBeZero < ActiveRecord::Migration
  def change
    change_column :solidus_line_items, :pre_tax_amount, :decimal, precision: 8, scale: 2, default: 0
    change_column :solidus_shipments, :pre_tax_amount, :decimal, precision: 8, scale: 2, default: 0
  end
end
