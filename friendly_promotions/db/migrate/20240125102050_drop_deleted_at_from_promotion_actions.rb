class DropDeletedAtFromPromotionActions < ActiveRecord::Migration[7.0]
  def change
    remove_column :friendly_promotion_actions, :deleted_at, :datetime, null: true
  end
end
