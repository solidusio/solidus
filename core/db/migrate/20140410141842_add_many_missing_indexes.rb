class AddManyMissingIndexes < ActiveRecord::Migration
  def change
    add_index :solidus_adjustments, [:adjustable_id, :adjustable_type]
    add_index :solidus_adjustments, :eligible
    add_index :solidus_adjustments, :order_id
    add_index :solidus_promotions, :code
    add_index :solidus_promotions, :expires_at
    add_index :solidus_states, :country_id
    add_index :solidus_stock_items, :deleted_at
    add_index :solidus_option_types, :position
    add_index :solidus_option_values, :position
    add_index :solidus_product_option_types, :option_type_id
    add_index :solidus_product_option_types, :product_id
    add_index :solidus_products_taxons, :position
    add_index :solidus_promotions, :starts_at
  end
end
