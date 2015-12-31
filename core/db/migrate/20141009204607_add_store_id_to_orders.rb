class AddStoreIdToOrders < ActiveRecord::Migration
  class Store < ActiveRecord::Base
    self.table_name = 'solidus_stores'
  end
  def change
    add_column :solidus_orders, :store_id, :integer
    default_store = Store.where(default: true).first
    if default_store
      Solidus::Order.where(store_id: nil).update_all(store_id: default_store.id)
    end
  end
end
