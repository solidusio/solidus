class AddApproverNameToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :approver_name, :string
  end
end
