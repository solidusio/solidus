class ConvertHabtmTablesToHmt < ActiveRecord::Migration
  def up
    add_columns :spree_taxons_promotion_rules, add_id: false
    add_columns :spree_properties_prototypes
    add_columns :spree_taxons_prototypes, add_id: false
    add_columns :spree_shipping_methods_zones

    rename_table :spree_taxons_promotion_rules, :spree_promotion_rule_taxons
    rename_table :spree_properties_prototypes, :spree_property_prototypes
    rename_table :spree_taxons_prototypes, :spree_prototype_taxons
    rename_table :spree_shipping_methods_zones, :spree_shipping_method_zones

    rename_table :spree_products_taxons, :spree_classifications
    rename_table :spree_roles_users, :spree_role_users
    rename_table :spree_promotion_rules_users, :spree_promotion_rule_users
    rename_table :spree_orders_promotions, :spree_order_promotions
  end

  def down
    remove_columns :spree_taxons_promotion_rules, remove_id: false
    remove_columns :spree_properties_prototypes
    remove_columns :spree_taxons_prototypes, remove_id: false
    remove_columns :spree_shipping_methods_zones

    rename_table :spree_promotion_rule_taxons, :spree_taxons_promotion_rules
    rename_table :spree_property_prototypes, :spree_properties_prototypes
    rename_table :spree_prototype_taxons, :spree_taxons_prototypes
    rename_table :spree_shipping_method_zones, :spree_shipping_methods_zones

    rename_table :spree_classifications, :spree_products_taxons
    rename_table :spree_role_users, :spree_roles_users
    rename_table :spree_promotion_rule_users, :spree_promotion_rules_users
    rename_table :spree_order_promotions, :spree_orders_promotions
  end

  private

  def add_columns(table, add_id: true)
    add_column table, :id, :primary_key if add_id
    add_column table, :created_at, :datetime
    add_column table, :updated_at, :datetime
  end

  def remove_columns(table, remove_id: true)
    remove_column table, :updated_at
    remove_column table, :created_at
    remove_column table, :id if remove_id
  end
end
