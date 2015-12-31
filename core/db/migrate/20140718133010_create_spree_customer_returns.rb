class CreateSpreeCustomerReturns < ActiveRecord::Migration
  def change
    create_table :solidus_customer_returns do |t|
      t.string :number
      t.integer :stock_location_id
      t.timestamps null: true
    end
  end
end
