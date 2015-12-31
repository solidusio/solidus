class DropReturnAuthorizationAmount < ActiveRecord::Migration
  def change
    remove_column :solidus_return_authorizations, :amount
  end
end
