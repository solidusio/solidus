class CreateUserGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :spree_user_groups do |t|
      t.string :group_name

      t.timestamps
    end
  end
end
