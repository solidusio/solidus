# All of these indexes were originally added in
# 20140410150358_correct_some_polymorphic_index_and_add_more_missing.rb
# However, most are necessary and were removed from that migration. This
# migration deletes any of the indexes left around in stores using the
# out-dated version of that migration
class RemoveUnnecessaryIndexes < ActiveRecord::Migration
  def up
    safe_remove_index :solidus_credit_cards, :address_id
    safe_remove_index :solidus_gateways, :active
    safe_remove_index :solidus_gateways, :test_mode
    safe_remove_index :solidus_inventory_units, :return_authorization_id
    safe_remove_index :solidus_line_items, :tax_category_id
    safe_remove_index :solidus_orders, :shipping_method_id
    safe_remove_index :solidus_orders, :confirmation_delivered
    safe_remove_index :solidus_prices, :deleted_at
    safe_remove_index :solidus_products, :shipping_category_id
    safe_remove_index :solidus_products, :tax_category_id
    safe_remove_index :solidus_shipping_methods, :deleted_at
    safe_remove_index :solidus_shipping_rates, :selected
    safe_remove_index :solidus_shipping_rates, :tax_rate_id
    safe_remove_index :solidus_stock_items, :backorderable
    safe_remove_index :solidus_stock_locations, :active
    safe_remove_index :solidus_stock_locations, :backorderable_default
    safe_remove_index :solidus_stock_locations, :propagate_all_variants
    safe_remove_index :solidus_tax_categories, :is_default
    safe_remove_index :solidus_tax_categories, :deleted_at
    safe_remove_index :solidus_tax_rates, :show_rate_in_label
    safe_remove_index :solidus_tax_rates, :included_in_price
    safe_remove_index :solidus_trackers, :active
    safe_remove_index :solidus_variants, :is_master
    safe_remove_index :solidus_variants, :deleted_at
    safe_remove_index :solidus_zones, :default_tax
  end

  def down
    safe_add_index :solidus_credit_cards, :address_id
    safe_add_index :solidus_gateways, :active
    safe_add_index :solidus_gateways, :test_mode
    safe_add_index :solidus_inventory_units, :return_authorization_id
    safe_add_index :solidus_line_items, :tax_category_id
    safe_add_index :solidus_orders, :shipping_method_id
    safe_add_index :solidus_orders, :confirmation_delivered
    safe_add_index :solidus_prices, :deleted_at
    safe_add_index :solidus_products, :shipping_category_id
    safe_add_index :solidus_products, :tax_category_id
    safe_add_index :solidus_shipping_methods, :deleted_at
    safe_add_index :solidus_shipping_rates, :selected
    safe_add_index :solidus_shipping_rates, :tax_rate_id
    safe_add_index :solidus_stock_items, :backorderable
    safe_add_index :solidus_stock_locations, :active
    safe_add_index :solidus_stock_locations, :backorderable_default
    safe_add_index :solidus_stock_locations, :propagate_all_variants
    safe_add_index :solidus_tax_categories, :is_default
    safe_add_index :solidus_tax_categories, :deleted_at
    safe_add_index :solidus_tax_rates, :show_rate_in_label
    safe_add_index :solidus_tax_rates, :included_in_price
    safe_add_index :solidus_trackers, :active
    safe_add_index :solidus_variants, :is_master
    safe_add_index :solidus_variants, :deleted_at
    safe_add_index :solidus_zones, :default_tax
  end

  private

  def safe_remove_index(table, column)
    remove_index(table, column) if index_exists?(table, column)
  end

  def safe_add_index(table, column)
    add_index(table, column) if column_exists?(table, column)
  end
end
