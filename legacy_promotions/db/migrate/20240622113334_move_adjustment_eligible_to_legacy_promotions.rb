class MoveAdjustmentEligibleToLegacyPromotions < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:spree_adjustments, :eligible)
      add_column(:spree_adjustments, :eligible, :boolean, default: true)
    end

    unless index_exists?(:spree_adjustments, :eligible)
      add_index :spree_adjustments, :eligible, name: "index_spree_adjustments_on_eligible"
    end
  end
end
