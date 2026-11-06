# frozen_string_literal: true

# After this migration, run `rake solidus_legacy_promotions:recalculate_usage_claims_counts`
# to count the existing uses of usage limited promotions.
class AddUsageClaimsCountToSpreePromotions < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_promotions, :usage_claims_count, :integer, default: 0, null: false
    add_column :spree_promotion_codes, :usage_claims_count, :integer, default: 0, null: false
  end
end
