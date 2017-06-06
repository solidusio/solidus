class AddSpreeApiAccessToSpreeUsers < ActiveRecord::Migration
  def change
    unless defined?(User)
      add_column :spree_users, :spree_api_access, :boolean, default: false
    end
  end
end
