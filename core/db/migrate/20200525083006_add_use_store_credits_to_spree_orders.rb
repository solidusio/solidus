class AddUseStoreCreditsToSpreeOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :use_store_credits, :boolean, default: nil
  end
end
