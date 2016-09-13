class RemoveConsideredRiskyFromSpreeOrders < ActiveRecord::Migration[4.2]
  def change
    remove_column :spree_orders, :considered_risky
  end
end
