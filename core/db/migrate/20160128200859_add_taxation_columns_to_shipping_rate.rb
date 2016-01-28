class AddTaxationColumnsToShippingRate < ActiveRecord::Migration
  def up
    add_column :spree_shipping_rates, :included_tax_total, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :spree_shipping_rates, :additional_tax_total, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :spree_shipping_rates, :adjustment_total, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :spree_shipping_rates, :promo_total, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :spree_shipping_rates, :pre_tax_amount, :decimal, precision: 12, scale: 4, null: false, default: 0.0
  end
end
