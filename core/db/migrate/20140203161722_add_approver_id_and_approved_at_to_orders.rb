class AddApproverIdAndApprovedAtToOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :approver_id, :integer
    add_column :solidus_orders, :approved_at, :datetime
  end
end
