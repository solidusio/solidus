# frozen_string_literal: true
class AddDefaultBillngFlagToUserAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_user_addresses, :default_billing, :boolean, default: false
  end
end
