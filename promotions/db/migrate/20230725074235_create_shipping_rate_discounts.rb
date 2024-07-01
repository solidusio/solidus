class CreateShippingRateDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_shipping_rate_discounts do |t|
      t.references :benefit, type: :bigint, null: false, foreign_key: { to_table: :solidus_promotions_benefits }, index: { name: "index_shipping_rate_discounts_on_benefit_id" }
      t.references :shipping_rate, type: :integer, null: false, foreign_key: { to_table: :spree_shipping_rates }, index: { name: "index_shipping_rate_discounts_on_shipping_rate_id" }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
