class CreateShippingRateDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_shipping_rate_discounts do |t|
      t.references :promotion_action, type: :bigint, null: false, foreign_key: { to_table: :friendly_promotion_actions }
      t.references :shipping_rate, type: :integer, null: false, foreign_key: { to_table: :spree_shipping_rates }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
