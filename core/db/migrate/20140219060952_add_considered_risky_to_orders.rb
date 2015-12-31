class AddConsideredRiskyToOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :considered_risky, :boolean, :default => false
  end
end
