class AddUncapturedAmountToPayments < ActiveRecord::Migration
  def change
    add_column :solidus_payments, :uncaptured_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
