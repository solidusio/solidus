class RenameSpreeRefundReturnAuthorizationId < ActiveRecord::Migration
  def change
    rename_column :solidus_refunds, :return_authorization_id, :customer_return_id
  end
end
