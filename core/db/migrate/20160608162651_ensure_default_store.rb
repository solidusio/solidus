class EnsureDefaultStore < ActiveRecord::Migration
  class Store < ActiveRecord::Base
    self.table_name = 'spree_stores'
  end

  def up
    unless Store.where(default: true).exists?
      store = Store.first
      raise "Database has no stores. One should have been created in a previous migration." unless store
      store.update_column(:default, true)
    end
  end
end
