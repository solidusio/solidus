class DropSpreeGateways < ActiveRecord::Migration
  def up
    drop_table :spree_gateways
  end

  def down
    create_table "spree_gateways" do |t|
      t.string   "type"
      t.string   "name"
      t.text     "description"
      t.boolean  "active",      default: true
      t.string   "environment", default: "development"
      t.string   "server",      default: "test"
      t.boolean  "test_mode",   default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "preferences"
    end
  end
end
