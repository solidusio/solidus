class AddRecipientToReturnAuthorization < ActiveRecord::Migration
  def change
    add_column :spree_return_authorizations, :recipient_id, :integer
    add_index :spree_return_authorizations, :recipient_id

    add_foreign_key :spree_return_authorizations, Spree.user_class.table_name, column: :recipient_id
  end
end
