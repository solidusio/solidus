class RemoveTaxRateFromShippingRate < ActiveRecord::Migration
  def up
    remove_column :spree_shipping_rates, :tax_rate_id
  end

  def down
    add_reference :spree_shipping_rates, :tax_rate, index: true, foreign_key: true
  end
end
