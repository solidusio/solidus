class AddPositionToStockLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_stock_locations, :position, :integer, default: 0
  end
end
