class AddMissingTimestampColumns < ActiveRecord::Migration
  def change
    # Missing updated_at
    add_column :friendly_id_slugs, :updated_at, :datetime, null: true

    # Missing created_at
    add_column :spree_countries, :created_at, :datetime, null: true
    add_column :spree_states, :created_at, :datetime, null: true
    add_column :spree_variants, :created_at, :datetime, null: true

    # Missing timestamps
    add_timestamps(:spree_option_values_variants, null: true)
    add_timestamps(:spree_products_taxons, null: true)
    add_timestamps(:spree_promotion_action_line_items, null: true)
    add_timestamps(:spree_promotion_actions, null: true)
    add_timestamps(:spree_reimbursement_credits, null: true)
    add_timestamps(:spree_roles, null: true)
    add_timestamps(:spree_variant_property_rule_values, null: true)
  end
end
