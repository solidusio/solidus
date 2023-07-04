class AddRuleTables < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_friendly_promotions_products_rules, force: :cascade do |t|
      t.references :product, index: true, null: false, foreign_key: { to_table: :spree_products }
      t.references :rule, index: true, null: false, foreign_key: { to_table: :solidus_friendly_promotions_rules }

      t.timestamps
    end

    create_table :solidus_friendly_promotions_rules_taxons, force: :cascade do |t|
      t.references :taxon, index: true, null: false, foreign_key: { to_table: :spree_taxons }
      t.references :rule, index: true, null: false, foreign_key: { to_table: :solidus_friendly_promotions_rules }

      t.timestamps
    end

    create_table :solidus_friendly_promotions_rules_users, force: :cascade do |t|
      t.references :user, index: true, null: false, foreign_key: { to_table: Spree.user_class.table_name }
      t.references :rule, index: true, null: false, foreign_key: { to_table: :solidus_friendly_promotions_rules }

      t.timestamps
    end

    create_table :solidus_friendly_promotions_rules_stores do |t|
      t.references :store, index: true, null: false, foreign_key: { to_table: :spree_users }
      t.references :rule, index: true, null: false

      t.timestamps
    end
  end
end
