class AddDefaultBillngFlagToUserAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_user_addresses, :default_billing, :boolean, default: false
  end
end
