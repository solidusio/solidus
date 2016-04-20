# All of these indexes were originally added in
# 20140410150358_correct_some_polymorphic_index_and_add_more_missing.rb
# However, most are necessary and were removed from that migration. This
# migration deletes any of the indexes left around in stores using the
# out-dated version of that migration
class RemoveUnnecessaryIndexes < ActiveRecord::Migration
  include Spree::MigrationHelpers

  def up
    safe_remove_index :spree_credit_cards, :address_id
    safe_remove_index :spree_gateways, :active
    safe_remove_index :spree_gateways, :test_mode
    safe_remove_index :spree_inventory_units, :return_authorization_id
    safe_remove_index :spree_line_items, :tax_category_id
    safe_remove_index :spree_orders, :shipping_method_id
    safe_remove_index :spree_orders, :confirmation_delivered
    safe_remove_index :spree_prices, :deleted_at
    safe_remove_index :spree_products, :shipping_category_id
    safe_remove_index :spree_products, :tax_category_id
    safe_remove_index :spree_shipping_methods, :deleted_at
    safe_remove_index :spree_shipping_rates, :selected
    safe_remove_index :spree_shipping_rates, :tax_rate_id
    safe_remove_index :spree_stock_items, :backorderable
    safe_remove_index :spree_stock_locations, :active
    safe_remove_index :spree_stock_locations, :backorderable_default
    safe_remove_index :spree_stock_locations, :propagate_all_variants
    safe_remove_index :spree_tax_categories, :is_default
    safe_remove_index :spree_tax_categories, :deleted_at
    safe_remove_index :spree_tax_rates, :show_rate_in_label
    safe_remove_index :spree_tax_rates, :included_in_price
    safe_remove_index :spree_trackers, :active
    safe_remove_index :spree_variants, :is_master
    safe_remove_index :spree_variants, :deleted_at
    safe_remove_index :spree_zones, :default_tax
  end

  def down
    safe_add_index :spree_credit_cards, :address_id
    safe_add_index :spree_gateways, :active
    safe_add_index :spree_gateways, :test_mode
    safe_add_index :spree_inventory_units, :return_authorization_id
    safe_add_index :spree_line_items, :tax_category_id
    safe_add_index :spree_orders, :shipping_method_id
    safe_add_index :spree_orders, :confirmation_delivered
    safe_add_index :spree_prices, :deleted_at
    safe_add_index :spree_products, :shipping_category_id
    safe_add_index :spree_products, :tax_category_id
    safe_add_index :spree_shipping_methods, :deleted_at
    safe_add_index :spree_shipping_rates, :selected
    safe_add_index :spree_shipping_rates, :tax_rate_id
    safe_add_index :spree_stock_items, :backorderable
    safe_add_index :spree_stock_locations, :active
    safe_add_index :spree_stock_locations, :backorderable_default
    safe_add_index :spree_stock_locations, :propagate_all_variants
    safe_add_index :spree_tax_categories, :is_default
    safe_add_index :spree_tax_categories, :deleted_at
    safe_add_index :spree_tax_rates, :show_rate_in_label
    safe_add_index :spree_tax_rates, :included_in_price
    safe_add_index :spree_trackers, :active
    safe_add_index :spree_variants, :is_master
    safe_add_index :spree_variants, :deleted_at
    safe_add_index :spree_zones, :default_tax
  end
end
