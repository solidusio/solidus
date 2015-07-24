class CorrectSomePolymorphicIndexAndAddMoreMissing < ActiveRecord::Migration
  def change
    add_index :spree_addresses, :country_id
    add_index :spree_addresses, :state_id

    remove_index :spree_adjustments, [:source_type, :source_id]
    add_index :spree_adjustments, [:source_id, :source_type]

    add_index :spree_inventory_units, :return_authorization_id

    add_index :spree_log_entries, [:source_id, :source_type]

    add_index :spree_orders, :approver_id
    add_index :spree_orders, :created_by_id
    add_index :spree_orders, :ship_address_id
    add_index :spree_orders, :bill_address_id
    add_index :spree_orders, :considered_risky

    add_index :spree_orders_promotions, [:order_id, :promotion_id]

    add_index :spree_payments, [:source_id, :source_type]

    add_index :spree_product_option_types, :position

    add_index :spree_product_properties, :position
    add_index :spree_product_properties, :property_id

    add_index :spree_promotion_action_line_items, :promotion_action_id
    add_index :spree_promotion_action_line_items, :variant_id

    add_index :spree_promotion_rules, :promotion_id

    add_index :spree_promotions, :advertise

    add_index :spree_return_authorizations, :number
    add_index :spree_return_authorizations, :order_id
    add_index :spree_return_authorizations, :stock_location_id

    add_index :spree_shipments, :address_id

    add_index :spree_shipping_methods, :tax_category_id

    add_index :spree_state_changes, [:stateful_id, :stateful_type]
    add_index :spree_state_changes, :user_id

    add_index :spree_stock_locations, :country_id
    add_index :spree_stock_locations, :state_id

    add_index :spree_tax_rates, :deleted_at
    add_index :spree_tax_rates, :tax_category_id
    add_index :spree_tax_rates, :zone_id

    add_index :spree_taxonomies, :position

    add_index :spree_taxons, :position

    add_index :spree_variants, :position
    add_index :spree_variants, :track_inventory

    add_index :spree_zone_members, :zone_id
    add_index :spree_zone_members, [:zoneable_id, :zoneable_type]
  end
end
