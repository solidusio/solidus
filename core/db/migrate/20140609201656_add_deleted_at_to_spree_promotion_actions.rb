class AddDeletedAtToSolidusPromotionActions < ActiveRecord::Migration
  def change
    add_column :solidus_promotion_actions, :deleted_at, :datetime
    add_index :solidus_promotion_actions, :deleted_at
  end
end
