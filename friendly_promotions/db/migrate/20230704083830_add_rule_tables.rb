class AddRuleTables < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_products_promotion_rules, force: :cascade do |t|
      t.references :product, index: true, null: false, foreign_key: { to_table: :spree_products }
      t.references :promotion_rule, index: true, null: false, foreign_key: { to_table: :friendly_promotion_rules }

      t.timestamps
    end

    create_table :friendly_promotion_rules_taxons, force: :cascade do |t|
      t.references :taxon, index: true, null: false, foreign_key: { to_table: :spree_taxons }
      t.references :promotion_rule, index: true, null: false, foreign_key: { to_table: :friendly_promotion_rules }

      t.timestamps
    end

    create_table :friendly_promotion_rules_users, force: :cascade do |t|
      t.references :user, index: true, null: false, foreign_key: { to_table: Spree.user_class.table_name }
      t.references :promotion_rule, index: true, null: false, foreign_key: { to_table: :friendly_promotion_rules }

      t.timestamps
    end

    create_table :friendly_promotion_rules_stores do |t|
      t.references :store, index: true, null: false, foreign_key: { to_table: :spree_stores }
      t.references :promotion_rule, index: true, null: false

      t.timestamps
    end
  end
end
