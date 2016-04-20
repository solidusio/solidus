class AddManyMissingIndexes < ActiveRecord::Migration
  include Spree::MigrationHelpers

  def change
    safe_add_index :spree_adjustments, [:adjustable_id, :adjustable_type]
    safe_add_index :spree_adjustments, :eligible
    safe_add_index :spree_adjustments, :order_id
    safe_add_index :spree_promotions, :code
    safe_add_index :spree_promotions, :expires_at
    safe_add_index :spree_states, :country_id
    safe_add_index :spree_stock_items, :deleted_at
    safe_add_index :spree_option_types, :position
    safe_add_index :spree_option_values, :position
    safe_add_index :spree_product_option_types, :option_type_id
    safe_add_index :spree_product_option_types, :product_id
    safe_add_index :spree_products_taxons, :position
    safe_add_index :spree_promotions, :starts_at
  end
end
