class AddFrontendViewableToSpreeOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_orders, :frontend_viewable, :boolean, default: true, null: false
  end
end
