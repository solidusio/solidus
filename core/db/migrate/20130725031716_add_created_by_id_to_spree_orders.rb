class AddCreatedByIdToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :created_by_id, :integer
  end
end
