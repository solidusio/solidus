# This is named the same as the migration in spree 3.0 so it will not be copied
# if that has already been run.
class RemoveTokenPermissionsTable < ActiveRecord::Migration
  def up
    drop_table :spree_tokenized_permissions
  end

  def down
    create_table "spree_tokenized_permissions" do |t|
      t.integer  "permissable_id"
      t.string   "permissable_type"
      t.string   "token"
      t.timestamps null: true
    end
  end
end
