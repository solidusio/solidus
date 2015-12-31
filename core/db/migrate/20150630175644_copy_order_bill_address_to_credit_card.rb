class CopyOrderBillAddressToCreditCard < ActiveRecord::Migration
  # Prevent everything from running in one giant transaction in postrgres.
  disable_ddl_transaction!

  def up
    Rake::Task["solidus:migrations:copy_order_bill_address_to_credit_card:up"].invoke
  end

  def down
    Rake::Task["solidus:migrations:copy_order_bill_address_to_credit_card:down"].invoke
  end
end
