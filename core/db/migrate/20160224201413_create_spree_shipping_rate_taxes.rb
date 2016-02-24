class CreateSpreeShippingRateTaxes < ActiveRecord::Migration
  def change
    create_table :spree_shipping_rate_taxes do |t|
      t.decimal :amount, precision: 8, scale: 2, default: 0.0, null: false
      t.references :tax_rate, index: true
      t.references :shipping_rate, index: true

      t.timestamps null: false
    end
  end
end
