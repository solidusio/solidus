class AddFulfillableToStockLocation < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :fulfillable, :boolean, default: true, null: false
  end
end
