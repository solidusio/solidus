class CreateAdjustmentPromotionCodeAssociation < ActiveRecord::Migration
  def change
    add_column :solidus_adjustments, :promotion_code_id, :integer
    add_index :solidus_adjustments, :promotion_code_id
  end
end
