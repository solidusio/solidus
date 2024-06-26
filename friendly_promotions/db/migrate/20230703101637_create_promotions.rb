class CreatePromotions < ActiveRecord::Migration[7.0]
  def change
    promotion_foreign_key = table_exists?(:spree_promotions) ? { to_table: :spree_promotions } : false

    create_table :solidus_promotions_promotions do |t|
      t.string :description
      t.datetime :expires_at, precision: nil
      t.datetime :starts_at, precision: nil
      t.string :name
      t.integer :usage_limit
      t.boolean :advertise, default: false
      t.string :path
      t.integer :per_code_usage_limit
      t.boolean :apply_automatically, default: false
      t.integer :lane, null: false, default: 1
      t.string :customer_label
      t.datetime :deleted_at
      t.references :original_promotion, type: :integer, index: { name: :index_original_promotion_id }, foreign_key: promotion_foreign_key

      t.timestamps
    end

    add_index :solidus_promotions_promotions, :deleted_at
  end
end
