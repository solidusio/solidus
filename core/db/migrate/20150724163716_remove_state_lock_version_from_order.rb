class RemoveStateLockVersionFromOrder < ActiveRecord::Migration[4.2]
  def up
    if column_exists? :spree_orders, :state_lock_version
      remove_column :spree_orders, :state_lock_version
    end
  end

  def down
    add_column :spree_orders, :state_lock_version, :integer, default: 0, null: false
  end
end
