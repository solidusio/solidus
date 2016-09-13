class RemoveUsageLimitFromPromotionCodes < ActiveRecord::Migration[4.2]
  def change
    remove_column :spree_promotion_codes, :usage_limit, :integer
  end
end
