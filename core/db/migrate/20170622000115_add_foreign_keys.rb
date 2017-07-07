class AddForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :spree_addresses, :spree_countries, column: :country_id
    add_foreign_key :spree_addresses, :spree_states, column: :state_id

    add_foreign_key :spree_credit_cards, :spree_users, column: :user_id
    add_foreign_key :spree_credit_cards, :spree_payment_methods, column: :payment_method_id
    add_foreign_key :spree_credit_cards, :spree_addresses, column: :address_id

    add_foreign_key :spree_customer_returns, :spree_stock_locations, column: :stock_location_id

    add_foreign_key :spree_inventory_units, :spree_variants, column: :variant_id
    add_foreign_key :spree_inventory_units, :spree_orders, column: :order_id
    add_foreign_key :spree_inventory_units, :spree_shipments, column: :shipment_id
    add_foreign_key :spree_inventory_units, :spree_line_items, column: :line_item_id
    add_foreign_key :spree_inventory_units, :spree_cartons, column: :carton_id

    add_foreign_key :spree_line_item_actions, :spree_line_items, column: :line_item_id
    add_foreign_key :spree_line_item_actions, :spree_promotion_actions, column: :action_id

    add_foreign_key :spree_line_items, :spree_variants, column: :variant_id
    add_foreign_key :spree_line_items, :spree_orders, column: :order_id
    add_foreign_key :spree_line_items, :spree_tax_categories, column: :tax_category_id

    add_foreign_key :spree_option_values, :spree_option_types, column: :option_type_id

    add_foreign_key :spree_option_values_variants, :spree_variants, column: :variant_id
    add_foreign_key :spree_option_values_variants, :spree_option_values, column: :option_value_id

    add_foreign_key :spree_orders, :spree_users, column: :user_id
    add_foreign_key :spree_orders, :spree_addresses, column: :bill_address_id
    add_foreign_key :spree_orders, :spree_addresses, column: :ship_address_id
    add_foreign_key :spree_orders, :spree_users, column: :created_by_id
    add_foreign_key :spree_orders, :spree_users, column: :approver_id
    add_foreign_key :spree_orders, :spree_users, column: :canceler_id
    add_foreign_key :spree_orders, :spree_stores, column: :store_id

    add_foreign_key :spree_orders_promotions, :spree_orders, column: :order_id
    add_foreign_key :spree_orders_promotions, :spree_promotions, column: :promotion_id
    add_foreign_key :spree_orders_promotions, :spree_promotion_codes, column: :promotion_code_id

    add_foreign_key :spree_payment_capture_events, :spree_payments, column: :payment_id

    add_foreign_key :spree_payments, :spree_orders, column: :order_id
    add_foreign_key :spree_payments, :spree_payment_methods, column: :payment_method_id

    add_foreign_key :spree_prices, :spree_variants, column: :variant_id

    add_foreign_key :spree_product_option_types, :spree_products, column: :product_id
    add_foreign_key :spree_product_option_types, :spree_option_types, column: :option_type_id

    #add_foreign_key :spree_product_promotion_rules, :spree_products, column: :product_id
    #add_foreign_key :spree_product_promotion_rules, :spree_promotion_rules, column: :promotion_rule_id

    add_foreign_key :spree_product_properties, :spree_products, column: :product_id
    add_foreign_key :spree_product_properties, :spree_properties, column: :property_id

    add_foreign_key :spree_products, :spree_tax_categories, column: :tax_category_id
    add_foreign_key :spree_products, :spree_shipping_categories, column: :shipping_category_id

    add_foreign_key :spree_products_taxons, :spree_products, column: :product_id
    add_foreign_key :spree_products_taxons, :spree_taxons, column: :taxon_id

    add_foreign_key :spree_promotion_action_line_items, :spree_promotion_actions, column: :promotion_action_id
    add_foreign_key :spree_promotion_action_line_items, :spree_variants, column: :variant_id

    add_foreign_key :spree_promotion_actions, :spree_promotions, column: :promotion_id

    #add_foreign_key :spree_promotion_code_batches, :spree_promotions, column: :promotion_id

    add_foreign_key :spree_promotion_codes, :spree_promotions, column: :promotion_id
    #add_foreign_key :spree_promotion_codes, :spree_promotion_code_batches, column: :promotion_code_batch_id

    #add_foreign_key :spree_promotion_rule_taxons, :spree_taxons, column: :taxon_id
    #add_foreign_key :spree_promotion_rule_taxons, :spree_promotion_rules, column: :promotion_rule_id

    add_foreign_key :spree_promotion_rules, :spree_promotions, column: :promotion_id

    add_foreign_key :spree_promotion_rules_users, :spree_users, column: :user_id
    add_foreign_key :spree_promotion_rules_users, :spree_promotion_rules, column: :promotion_rule_id

    add_foreign_key :spree_promotions, :spree_promotion_categories, column: :promotion_category_id

    add_foreign_key :spree_refunds, :spree_payments, column: :payment_id
    add_foreign_key :spree_refunds, :spree_refund_reasons, column: :refund_reason_id

    add_foreign_key :spree_reimbursement_credits, :spree_reimbursements, column: :reimbursement_id

    add_foreign_key :spree_reimbursements, :spree_customer_returns, column: :customer_return_id
    add_foreign_key :spree_reimbursements, :spree_orders, column: :order_id

    add_foreign_key :spree_return_authorizations, :spree_orders, column: :order_id
    add_foreign_key :spree_return_authorizations, :spree_stock_locations, column: :stock_location_id
    add_foreign_key :spree_return_authorizations, :spree_return_reasons, column: :return_reason_id

    add_foreign_key :spree_return_items, :spree_return_authorizations, column: :return_authorization_id
    add_foreign_key :spree_return_items, :spree_inventory_units, column: :inventory_unit_id
    add_foreign_key :spree_return_items, :spree_customer_returns, column: :customer_return_id
    add_foreign_key :spree_return_items, :spree_reimbursements, column: :reimbursement_id
    add_foreign_key :spree_return_items, :spree_reimbursement_types, column: :preferred_reimbursement_type_id
    add_foreign_key :spree_return_items, :spree_reimbursement_types, column: :override_reimbursement_type_id
    add_foreign_key :spree_return_items, :spree_return_reasons, column: :return_reason_id

    add_foreign_key :spree_roles_users, :spree_roles, column: :role_id
    add_foreign_key :spree_roles_users, :spree_users, column: :user_id

    add_foreign_key :spree_shipments, :spree_orders, column: :order_id
    add_foreign_key :spree_shipments, :spree_stock_locations, column: :stock_location_id

    add_foreign_key :spree_shipping_method_categories, :spree_shipping_methods, column: :shipping_method_id
    add_foreign_key :spree_shipping_method_categories, :spree_shipping_categories, column: :shipping_category_id

    add_foreign_key :spree_shipping_method_zones, :spree_shipping_methods, column: :shipping_method_id
    add_foreign_key :spree_shipping_method_zones, :spree_zones, column: :zone_id

    add_foreign_key :spree_shipping_methods, :spree_tax_categories, column: :tax_category_id

    add_foreign_key :spree_shipping_rate_taxes, :spree_tax_rates, column: :tax_rate_id
    add_foreign_key :spree_shipping_rate_taxes, :spree_shipping_rates, column: :shipping_rate_id

    add_foreign_key :spree_shipping_rates, :spree_shipments, column: :shipment_id
    add_foreign_key :spree_shipping_rates, :spree_shipping_methods, column: :shipping_method_id

    add_foreign_key :spree_states, :spree_countries, column: :country_id

    add_foreign_key :spree_stock_items, :spree_stock_locations, column: :stock_location_id
    add_foreign_key :spree_stock_items, :spree_variants, column: :variant_id

    add_foreign_key :spree_stock_locations, :spree_states, column: :state_id
    add_foreign_key :spree_stock_locations, :spree_countries, column: :country_id

    add_foreign_key :spree_stock_movements, :spree_stock_items, column: :stock_item_id

    add_foreign_key :spree_stock_transfers, :spree_stock_locations, column: :source_location_id
    add_foreign_key :spree_stock_transfers, :spree_stock_locations, column: :destination_location_id
    add_foreign_key :spree_stock_transfers, :spree_users, column: :created_by_id
    add_foreign_key :spree_stock_transfers, :spree_users, column: :closed_by_id
    add_foreign_key :spree_stock_transfers, :spree_users, column: :finalized_by_id

    add_foreign_key :spree_store_credit_events, :spree_store_credits, column: :store_credit_id
    add_foreign_key :spree_store_credit_events, :spree_store_credit_update_reasons, column: :update_reason_id

    add_foreign_key :spree_store_credits, :spree_users, column: :user_id
    add_foreign_key :spree_store_credits, :spree_store_credit_categories, column: :category_id
    add_foreign_key :spree_store_credits, :spree_users, column: :created_by_id
    add_foreign_key :spree_store_credits, :spree_store_credit_types, column: :type_id

    add_foreign_key :spree_store_payment_methods, :spree_stores, column: :store_id
    add_foreign_key :spree_store_payment_methods, :spree_payment_methods, column: :payment_method_id

    #add_foreign_key :spree_tax_rate_tax_categories, :spree_tax_categories, column: :tax_category_id
    #add_foreign_key :spree_tax_rate_tax_categories, :spree_tax_rates, column: :tax_rate_id

    add_foreign_key :spree_tax_rates, :spree_zones, column: :zone_id

    add_foreign_key :spree_taxons, :spree_taxons, column: :parent_id
    add_foreign_key :spree_taxons, :spree_taxonomies, column: :taxonomy_id

    add_foreign_key :spree_transfer_items, :spree_variants, column: :variant_id
    add_foreign_key :spree_transfer_items, :spree_stock_transfers, column: :stock_transfer_id

    add_foreign_key :spree_unit_cancels, :spree_inventory_units, column: :inventory_unit_id

    add_foreign_key :spree_user_addresses, :spree_users, column: :user_id
    add_foreign_key :spree_user_addresses, :spree_addresses, column: :address_id

    add_foreign_key :spree_users, :spree_addresses, column: :ship_address_id
    add_foreign_key :spree_users, :spree_addresses, column: :bill_address_id

    add_foreign_key :spree_variants, :spree_products, column: :product_id
    add_foreign_key :spree_variants, :spree_tax_categories, column: :tax_category_id

    #add_foreign_key :spree_wallet_payment_sources, :spree_users, column: :user_id

    add_foreign_key :spree_zone_members, :spree_zones, column: :zone_id
  end
end
