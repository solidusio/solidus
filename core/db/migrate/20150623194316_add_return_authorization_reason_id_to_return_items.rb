class AddReturnAuthorizationReasonIdToReturnItems < ActiveRecord::Migration
  def change
    add_column :spree_return_items, :return_authorization_reason_id, :integer
  end
end
