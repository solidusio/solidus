class AddUsageCountToPromotions < ActiveRecord::Migration
  def change
    add_column :spree_promotions, :usage_count, :integer, default: 0
  end
end
