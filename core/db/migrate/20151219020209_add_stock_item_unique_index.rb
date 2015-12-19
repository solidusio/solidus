class AddStockItemUniqueIndex < ActiveRecord::Migration
  def change
    # Add a database-level uniqueness constraint for databases that support it
    # (postgres & sqlite)
    if connection.adapter_name =~ /postgres|sqlite/i
      add_index 'spree_stock_items', ['variant_id', 'stock_location_id'], where: 'deleted_at is null', unique: true
    end
  end
end
