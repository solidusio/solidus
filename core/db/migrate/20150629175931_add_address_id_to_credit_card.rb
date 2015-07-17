class AddAddressIdToCreditCard < ActiveRecord::Migration
  def change
    add_column :spree_credit_cards, :address_id, :integer
  end
end
