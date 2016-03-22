class RemoveCurrencyFromLineItem < ActiveRecord::Migration
  def change
    remove_column :spree_line_items, :currency, :string
  end
end
