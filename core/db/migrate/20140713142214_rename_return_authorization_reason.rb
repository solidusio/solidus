class RenameReturnAuthorizationReason < ActiveRecord::Migration
  def change
    rename_column :solidus_return_authorizations, :reason, :memo
  end
end
