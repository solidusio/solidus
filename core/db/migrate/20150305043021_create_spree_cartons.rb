class CreateSolidusCartons < ActiveRecord::Migration
  def change
    create_table "solidus_cartons" do |t|
      t.string "number"

      t.string "external_number"

      t.references "stock_location", index: true
      t.references "address"
      t.references "shipping_method"

      t.string "tracking"

      t.datetime "shipped_at"

      t.timestamps null: true
    end

    add_index "solidus_cartons", "number", unique: true
    add_index "solidus_cartons", "external_number"

    add_column "solidus_inventory_units", "carton_id", :integer
  end
end
