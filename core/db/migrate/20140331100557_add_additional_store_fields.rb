class AddAdditionalStoreFields < ActiveRecord::Migration
  def change
    add_column :solidus_stores, :code, :string unless column_exists?(:solidus_stores, :code)
    add_column :solidus_stores, :default, :boolean, default: false, null: false unless column_exists?(:solidus_stores, :default)
    add_index :solidus_stores, :code
    add_index :solidus_stores, :default
  end
end
