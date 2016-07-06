class AddApproverNameToSpreeOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_orders, :approver_name, :string
  end
end
