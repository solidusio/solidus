class AddCurrencyToLineItems < ActiveRecord::Migration
  def change
    add_column :solidus_line_items, :currency, :string
  end
end
