class CorrectSomePolymorphicIndexAndAddMoreMissing < ActiveRecord::Migration
  include Spree::MigrationHelpers

  def change
    safe_add_index :spree_addresses, :country_id
    safe_add_index :spree_addresses, :state_id

    safe_remove_index :spree_adjustments, [:source_type, :source_id]
    safe_add_index :spree_adjustments, [:source_id, :source_type]

    safe_add_index :spree_inventory_units, :return_authorization_id

    safe_add_index :spree_log_entries, [:source_id, :source_type]

    safe_add_index :spree_orders, :approver_id
    safe_add_index :spree_orders, :created_by_id
    safe_add_index :spree_orders, :ship_address_id
    safe_add_index :spree_orders, :bill_address_id
    safe_add_index :spree_orders, :considered_risky

    safe_add_index :spree_orders_promotions, [:order_id, :promotion_id]

    safe_add_index :spree_payments, [:source_id, :source_type]

    safe_add_index :spree_product_option_types, :position

    safe_add_index :spree_product_properties, :position
    safe_add_index :spree_product_properties, :property_id

    safe_add_index :spree_promotion_action_line_items, :promotion_action_id
    safe_add_index :spree_promotion_action_line_items, :variant_id

    safe_add_index :spree_promotion_rules, :promotion_id

    safe_add_index :spree_promotions, :advertise

    safe_add_index :spree_return_authorizations, :number
    safe_add_index :spree_return_authorizations, :order_id
    safe_add_index :spree_return_authorizations, :stock_location_id

    safe_add_index :spree_shipments, :address_id

    safe_add_index :spree_shipping_methods, :tax_category_id

    safe_add_index :spree_state_changes, [:stateful_id, :stateful_type]
    safe_add_index :spree_state_changes, :user_id

    safe_add_index :spree_stock_locations, :country_id
    safe_add_index :spree_stock_locations, :state_id

    safe_add_index :spree_tax_rates, :deleted_at
    safe_add_index :spree_tax_rates, :tax_category_id
    safe_add_index :spree_tax_rates, :zone_id

    safe_add_index :spree_taxonomies, :position

    safe_add_index :spree_taxons, :position

    safe_add_index :spree_variants, :position
    safe_add_index :spree_variants, :track_inventory

    safe_add_index :spree_zone_members, :zone_id
    safe_add_index :spree_zone_members, [:zoneable_id, :zoneable_type]
  end
end
