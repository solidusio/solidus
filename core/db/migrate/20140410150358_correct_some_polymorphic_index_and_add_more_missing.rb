class CorrectSomePolymorphicIndexAndAddMoreMissing < ActiveRecord::Migration
  def change
    add_index :solidus_addresses, :country_id
    add_index :solidus_addresses, :state_id

    remove_index :solidus_adjustments, [:source_type, :source_id]
    add_index :solidus_adjustments, [:source_id, :source_type]

    add_index :solidus_inventory_units, :return_authorization_id

    add_index :solidus_log_entries, [:source_id, :source_type]

    add_index :solidus_orders, :approver_id
    add_index :solidus_orders, :created_by_id
    add_index :solidus_orders, :ship_address_id
    add_index :solidus_orders, :bill_address_id
    add_index :solidus_orders, :considered_risky

    add_index :solidus_orders_promotions, [:order_id, :promotion_id]

    add_index :solidus_payments, [:source_id, :source_type]

    add_index :solidus_product_option_types, :position

    add_index :solidus_product_properties, :position
    add_index :solidus_product_properties, :property_id

    add_index :solidus_promotion_action_line_items, :promotion_action_id
    add_index :solidus_promotion_action_line_items, :variant_id

    add_index :solidus_promotion_rules, :promotion_id

    add_index :solidus_promotions, :advertise

    add_index :solidus_return_authorizations, :number
    add_index :solidus_return_authorizations, :order_id
    add_index :solidus_return_authorizations, :stock_location_id

    add_index :solidus_shipments, :address_id

    add_index :solidus_shipping_methods, :tax_category_id

    add_index :solidus_state_changes, [:stateful_id, :stateful_type]
    add_index :solidus_state_changes, :user_id

    add_index :solidus_stock_locations, :country_id
    add_index :solidus_stock_locations, :state_id

    add_index :solidus_tax_rates, :deleted_at
    add_index :solidus_tax_rates, :tax_category_id
    add_index :solidus_tax_rates, :zone_id

    add_index :solidus_taxonomies, :position

    add_index :solidus_taxons, :position

    add_index :solidus_variants, :position
    add_index :solidus_variants, :track_inventory

    add_index :solidus_zone_members, :zone_id
    add_index :solidus_zone_members, [:zoneable_id, :zoneable_type]
  end
end
