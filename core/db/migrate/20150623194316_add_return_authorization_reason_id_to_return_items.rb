class AddReturnAuthorizationReasonIdToReturnItems < ActiveRecord::Migration
  def change
    rename_table :spree_return_authorization_reasons, :spree_return_reasons
    rename_column :spree_return_authorizations, :return_authorization_reason_id, :return_reason_id
    add_column :spree_return_items, :return_reason_id, :integer
  end
end
