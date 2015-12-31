class AddItemCountToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :item_count, :integer, :default => 0
  end
end
