class RemoveStateLockVersionFromOrder < ActiveRecord::Migration
  def up
    if column_exists? :solidus_orders, :state_lock_version
      remove_column :solidus_orders, :state_lock_version
    end
  end

  def down
    add_column :solidus_orders, :state_lock_version, :integer, default: 0, null: false
  end
end
