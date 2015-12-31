class AddFrontendViewableToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :frontend_viewable, :boolean, default: true, null: false
  end
end
