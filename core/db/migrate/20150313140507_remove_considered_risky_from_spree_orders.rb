class RemoveConsideredRiskyFromSolidusOrders < ActiveRecord::Migration
  def change
    remove_column :solidus_orders, :considered_risky
  end
end
