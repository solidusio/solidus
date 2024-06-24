class AddPromotionCodeIdToSpreeAdjustments < ActiveRecord::Migration[5.0]
  def up
    unless column_exists?(:spree_adjustments, :promotion_code_id)
      add_column :spree_adjustments, :promotion_code_id, :integer
    end
    unless index_exists?(:spree_adjustments, :promotion_code_id)
      add_index :spree_adjustments, :promotion_code_id, name: "index_spree_adjustments_on_promotion_code_id"
    end
  end
end
