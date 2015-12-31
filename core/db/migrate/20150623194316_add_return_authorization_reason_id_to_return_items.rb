class AddReturnAuthorizationReasonIdToReturnItems < ActiveRecord::Migration
  def change
    rename_table :solidus_return_authorization_reasons, :solidus_return_reasons
    rename_column :solidus_return_authorizations, :return_authorization_reason_id, :return_reason_id
    add_column :solidus_return_items, :return_reason_id, :integer
  end
end
