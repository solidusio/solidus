class RemoveConsideredRiskyFromSpreeOrders < ActiveRecord::Migration
  def change
    remove_column :spree_orders, :considered_risky
  end
end
