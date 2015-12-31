class AddAddressIdToCreditCard < ActiveRecord::Migration
  def change
    add_column :solidus_credit_cards, :address_id, :integer
  end
end
