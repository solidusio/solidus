class DropUnusedPromoActionLineItems < ActiveRecord::Migration[5.2]
  def change
    drop_table :spree_promotion_action_line_items, force: :cascade do |t|
      t.integer "promotion_action_id"
      t.integer "variant_id"
      t.integer "quantity", default: 1
      t.datetime "created_at", precision: 6
      t.datetime "updated_at", precision: 6
      t.index ["promotion_action_id"], name: "index_spree_promotion_action_line_items_on_promotion_action_id"
      t.index ["variant_id"], name: "index_spree_promotion_action_line_items_on_variant_id"
    end
  end
end
