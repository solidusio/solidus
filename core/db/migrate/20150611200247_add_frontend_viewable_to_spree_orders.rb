class AddFrontendViewableToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :frontend_viewable, :boolean, default: true, null: false
  end
end
