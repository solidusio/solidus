class CreateSpreePermissionSetsInCore < ActiveRecord::Migration[7.0]
  def change
    create_table :spree_permission_sets, if_not_exists: true do |t|
      t.string :name
      t.string :set
      t.timestamps null: false
    end
  end
end
