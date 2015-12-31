class AddUserIdToSpreeCreditCards < ActiveRecord::Migration
  def change
    unless Solidus::CreditCard.column_names.include? "user_id"
      add_column :solidus_credit_cards, :user_id, :integer
      add_index :solidus_credit_cards, :user_id
    end

    unless Solidus::CreditCard.column_names.include? "payment_method_id"
      add_column :solidus_credit_cards, :payment_method_id, :integer
      add_index :solidus_credit_cards, :payment_method_id
    end
  end
end
