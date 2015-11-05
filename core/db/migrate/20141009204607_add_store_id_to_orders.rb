class AddStoreIdToOrders < ActiveRecord::Migration
  class Store < ActiveRecord::Base
    self.table_name = 'spree_stores'
  end
  def change
    add_column :spree_orders, :store_id, :integer
    default_store = Store.where(default: true).first
    if default_store
      Spree::Order.where(store_id: nil).update_all(store_id: default_store.id)
    end
  end
end
