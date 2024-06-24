class RenameFriendlyPromotionActionsToFriendlyBenefits < ActiveRecord::Migration[7.0]
  def change
    rename_table :friendly_promotion_actions, :friendly_benefits
    rename_column :friendly_conditions, :action_id, :benefit_id
    rename_column :spree_line_items, :managed_by_order_action_id, :managed_by_order_benefit_id
    rename_column :friendly_shipping_rate_discounts, :promotion_action_id, :benefit_id
    update_benefit_type_sql = <<~SQL
      UPDATE friendly_benefits
      SET type = REPLACE(type, 'SolidusFriendlyPromotions::Actions', 'SolidusFriendlyPromotions::Benefits')
    SQL
    execute(update_benefit_type_sql)
    update_adjustment_source_type_sql = <<~SQL
      UPDATE spree_adjustments
      SET source_type = REPLACE(source_type, 'SolidusFriendlyPromotions::Actions', 'SolidusFriendlyPromotions::Benefits')
      WHERE source_type LIKE 'SolidusFriendlyPromotions::Actions%'
    SQL
    execute(update_adjustment_source_type_sql)
  end
end
