class AddCvvResultCodeAndCvvResultMessageToSolidusPayments < ActiveRecord::Migration
  def change
    add_column :solidus_payments, :cvv_response_code, :string
    add_column :solidus_payments, :cvv_response_message, :string
  end
end
