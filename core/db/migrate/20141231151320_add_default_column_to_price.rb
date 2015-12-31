class AddDefaultColumnToPrice < ActiveRecord::Migration
  def change
    add_column :solidus_prices, :is_default, :boolean, default: true, null: false
  end
end
