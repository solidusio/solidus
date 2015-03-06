class CreateSpreeCartons < ActiveRecord::Migration
  def change
    create_table "spree_cartons" do |t|
      t.string "number"

      t.string "external_number"

      t.references "stock_location", index: true
      t.references "address"
      t.references "shipping_method"

      t.string "tracking"

      t.datetime "shipped_at"

      t.timestamps
    end

    add_index "spree_cartons", "number", unique: true
    add_index "spree_cartons", "external_number"

    add_column "spree_inventory_units", "carton_id", :integer, index: true
  end
end
