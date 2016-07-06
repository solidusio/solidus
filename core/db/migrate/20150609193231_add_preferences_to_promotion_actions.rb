class AddPreferencesToPromotionActions < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_promotion_actions, :preferences, :text
  end
end
