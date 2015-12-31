class AddPositionToStockLocation < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :position, :integer, :default => 0
  end
end