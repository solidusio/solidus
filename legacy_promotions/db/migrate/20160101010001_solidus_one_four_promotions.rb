# frozen_string_literal: true

class SolidusOneFourPromotions < ActiveRecord::Migration[5.0]
  def up
    unless table_exists?(:spree_orders_promotions)
      create_table "spree_orders_promotions", force: :cascade do |t|
        t.integer "order_id"
        t.integer "promotion_id"
        t.integer "promotion_code_id"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["order_id", "promotion_id"], name: "index_spree_orders_promotions_on_order_id_and_promotion_id"
        t.index ["promotion_code_id"], name: "index_spree_orders_promotions_on_promotion_code_id"
      end
    end

    unless table_exists?(:spree_product_promotion_rules)
      create_table "spree_product_promotion_rules", force: :cascade do |t|
        t.integer "product_id"
        t.integer "promotion_rule_id"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["product_id"], name: "index_products_promotion_rules_on_product_id"
        t.index ["promotion_rule_id"], name: "index_products_promotion_rules_on_promotion_rule_id"
      end
    end

    unless table_exists?(:spree_promotion_actions)
      create_table "spree_promotion_actions", force: :cascade do |t|
        t.integer "promotion_id"
        t.integer "position"
        t.string "type"
        t.datetime "deleted_at"
        t.text "preferences"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["deleted_at"], name: "index_spree_promotion_actions_on_deleted_at"
        t.index ["id", "type"], name: "index_spree_promotion_actions_on_id_and_type"
        t.index ["promotion_id"], name: "index_spree_promotion_actions_on_promotion_id"
      end
    end

    unless table_exists?(:spree_promotion_categories)
      create_table "spree_promotion_categories", force: :cascade do |t|
        t.string "name"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.string "code"
      end
    end

    unless table_exists?(:spree_promotion_codes)
      create_table "spree_promotion_codes", force: :cascade do |t|
        t.integer "promotion_id", null: false
        t.string "value", null: false
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["promotion_id"], name: "index_spree_promotion_codes_on_promotion_id"
        t.index ["value"], name: "index_spree_promotion_codes_on_value", unique: true
      end
    end

    unless table_exists?(:spree_promotion_rule_taxons)
      create_table "spree_promotion_rule_taxons", force: :cascade do |t|
        t.integer "taxon_id"
        t.integer "promotion_rule_id"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["promotion_rule_id"], name: "index_spree_promotion_rule_taxons_on_promotion_rule_id"
        t.index ["taxon_id"], name: "index_spree_promotion_rule_taxons_on_taxon_id"
      end
    end

    unless table_exists?(:spree_promotion_rules)
      create_table "spree_promotion_rules", force: :cascade do |t|
        t.integer "promotion_id"
        t.integer "product_group_id"
        t.string "type"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.string "code"
        t.text "preferences"
        t.index ["product_group_id"], name: "index_promotion_rules_on_product_group_id"
        t.index ["promotion_id"], name: "index_spree_promotion_rules_on_promotion_id"
      end
    end

    unless table_exists?(:spree_promotion_rules_users)
      create_table "spree_promotion_rules_users", force: :cascade do |t|
        t.integer "user_id"
        t.integer "promotion_rule_id"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["promotion_rule_id"], name: "index_promotion_rules_users_on_promotion_rule_id"
        t.index ["user_id"], name: "index_promotion_rules_users_on_user_id"
      end
    end

    unless table_exists?(:spree_promotions)
      create_table "spree_promotions", force: :cascade do |t|
        t.string "description"
        t.datetime "expires_at"
        t.datetime "starts_at"
        t.string "name"
        t.string "type"
        t.integer "usage_limit"
        t.string "match_policy", default: "all"
        t.string "code"
        t.boolean "advertise", default: false
        t.string "path"
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.integer "promotion_category_id"
        t.integer "per_code_usage_limit"
        t.boolean "apply_automatically", default: false
        t.index ["advertise"], name: "index_spree_promotions_on_advertise"
        t.index ["apply_automatically"], name: "index_spree_promotions_on_apply_automatically"
        t.index ["code"], name: "index_spree_promotions_on_code"
        t.index ["expires_at"], name: "index_spree_promotions_on_expires_at"
        t.index ["id", "type"], name: "index_spree_promotions_on_id_and_type"
        t.index ["promotion_category_id"], name: "index_spree_promotions_on_promotion_category_id"
        t.index ["starts_at"], name: "index_spree_promotions_on_starts_at"
      end
    end

    unless table_exists?(:spree_line_item_actions)
      create_table "spree_line_item_actions", force: :cascade do |t|
        t.integer "line_item_id", null: false
        t.integer "action_id", null: false
        t.integer "quantity", default: 0
        t.datetime "created_at", precision: 6
        t.datetime "updated_at", precision: 6
        t.index ["action_id"], name: "index_spree_line_item_actions_on_action_id"
        t.index ["line_item_id"], name: "index_spree_line_item_actions_on_line_item_id"
      end
    end
  end
end
