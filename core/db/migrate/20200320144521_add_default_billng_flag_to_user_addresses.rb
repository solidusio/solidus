# frozen_string_literal: true

require "spree/migration"

class AddDefaultBillngFlagToUserAddresses < Spree::Migration
  def change
    add_column :spree_user_addresses, :default_billing, :boolean, default: false
  end
end
