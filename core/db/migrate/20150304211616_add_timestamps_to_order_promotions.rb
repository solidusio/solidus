class AddTimestampsToOrderPromotions < ActiveRecord::Migration
  def change
    add_column :solidus_orders_promotions, :created_at, :datetime
    add_column :solidus_orders_promotions, :updated_at, :datetime
  end
end
