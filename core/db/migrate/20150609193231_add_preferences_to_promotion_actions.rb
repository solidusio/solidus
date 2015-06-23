class AddPreferencesToPromotionActions < ActiveRecord::Migration
  def change
    add_column :spree_promotion_actions, :preferences, :text
  end
end
