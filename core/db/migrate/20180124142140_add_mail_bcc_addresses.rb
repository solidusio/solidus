class AddMailBccAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_stores, :bcc_addresses, :string
  end
end
