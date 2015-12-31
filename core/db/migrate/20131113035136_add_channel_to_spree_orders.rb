class AddChannelToSolidusOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :channel, :string, default: "solidus"
  end
end
