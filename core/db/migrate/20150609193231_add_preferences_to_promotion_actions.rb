class AddPreferencesToPromotionActions < ActiveRecord::Migration
  def change
    add_column :solidus_promotion_actions, :preferences, :text
  end
end
