class AddDescriptionToSpreeRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_roles, :description, :text
  end
end
