class RemoveUsageLimitFromPromotionCodes < ActiveRecord::Migration
  def change
    remove_column :solidus_promotion_codes, :usage_limit, :integer
  end
end
