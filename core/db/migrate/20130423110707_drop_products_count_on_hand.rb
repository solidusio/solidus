class DropProductsCountOnHand < ActiveRecord::Migration
  def up
    remove_column :solidus_products, :count_on_hand
  end
end
