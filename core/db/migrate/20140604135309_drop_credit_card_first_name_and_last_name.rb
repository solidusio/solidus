class DropCreditCardFirstNameAndLastName < ActiveRecord::Migration
  def change
    remove_column :solidus_credit_cards, :first_name, :string
    remove_column :solidus_credit_cards, :last_name, :string
  end
end
