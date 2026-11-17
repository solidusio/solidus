# frozen_string_literal: true

# After this migration, run `rake solidus_promotions:recalculate_usage_claims_counts`
# to count the existing uses of usage limited promotions.
class AddUsageClaimsCountToSolidusPromotions < ActiveRecord::Migration[7.0]
  def change
    add_column :solidus_promotions_promotions, :usage_claims_count, :integer, default: 0, null: false,
      comment: "Number of uses claimed by completed or completing orders, used to enforce the usage limit"
    add_column :solidus_promotions_promotion_codes, :usage_claims_count, :integer, default: 0, null: false,
      comment: "Number of uses claimed by completed or completing orders, used to enforce the per code usage limit"
  end
end
