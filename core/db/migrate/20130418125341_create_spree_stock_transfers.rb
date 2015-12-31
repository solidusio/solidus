class CreateSpreeStockTransfers < ActiveRecord::Migration
  def change
    create_table :solidus_stock_transfers do |t|
      t.string :type
      t.string :reference_number
      t.integer :source_location_id
      t.integer :destination_location_id
      t.timestamps null: true
    end

    add_index :solidus_stock_transfers, :source_location_id
    add_index :solidus_stock_transfers, :destination_location_id
  end
end
