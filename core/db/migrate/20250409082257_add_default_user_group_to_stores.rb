class AddDefaultUserGroupToStores < ActiveRecord::Migration[7.0]
  def change
    change_table :spree_stores do |t|
      t.references :default_cart_user_group, type: :integer, foreign_key: { to_table: :spree_user_groups }
      t.boolean :enforce_group_upon_signup, default: false
    end
  end
end
