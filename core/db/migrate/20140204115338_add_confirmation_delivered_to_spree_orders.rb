class AddConfirmationDeliveredToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :confirmation_delivered, :boolean, default: false
  end
end
