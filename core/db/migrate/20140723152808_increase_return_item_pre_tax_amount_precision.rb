class IncreaseReturnItemPreTaxAmountPrecision < ActiveRecord::Migration
  def up
    change_column :solidus_return_items, :pre_tax_amount, :decimal, precision: 12, scale: 4, default: 0.0, null: false
    change_column :solidus_return_items, :included_tax_total, :decimal, precision: 12, scale: 4, default: 0.0, null: false
    change_column :solidus_return_items, :additional_tax_total, :decimal, precision: 12, scale: 4, default: 0.0, null: false
  end

  def down
    change_column :solidus_return_items, :pre_tax_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    change_column :solidus_return_items, :included_tax_total, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    change_column :solidus_return_items, :additional_tax_total, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
