class AddOrderIdIndexToPayments < ActiveRecord::Migration
  def self.up
    add_index :solidus_payments, :order_id
  end

  def self.down
    remove_index :solidus_payments, :order_id
  end
end
