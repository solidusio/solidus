class RemovePromotionRulesPromotionId < ActiveRecord::Migration[7.0]
  def up
    remove_column :friendly_promotion_rules, :promotion_id
  end
end
