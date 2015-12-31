class RemoveUncapturedAmountFromSolidusPayments < ActiveRecord::Migration
  def change
    remove_column :solidus_payments, :uncaptured_amount
  end
end
