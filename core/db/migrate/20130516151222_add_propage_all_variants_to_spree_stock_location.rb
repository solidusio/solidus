class AddPropageAllVariantsToSolidusStockLocation < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :propagate_all_variants, :boolean, default: true
  end
end
