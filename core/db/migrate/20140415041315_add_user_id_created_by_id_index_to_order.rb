class AddUserIdCreatedByIdIndexToOrder < ActiveRecord::Migration
  def change
    add_index :solidus_orders, [:user_id, :created_by_id]
  end
end
