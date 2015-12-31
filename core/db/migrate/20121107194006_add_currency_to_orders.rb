class AddCurrencyToOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :currency, :string
  end
end
