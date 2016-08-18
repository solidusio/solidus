class AddPerCodeUsageLimitToPromotions < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_promotions, :per_code_usage_limit, :integer
  end
end
