class AllowNullPromotionIds < ActiveRecord::Migration[7.0]
  def up
    change_column_null :friendly_promotion_actions, :promotion_id, true
  end

  def down
    change_column_null :friendly_promotion_actions, :promotion_id, false
  end
end
