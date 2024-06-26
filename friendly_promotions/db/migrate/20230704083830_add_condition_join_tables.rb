class AddConditionJoinTables < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_condition_products, force: :cascade do |t|
      t.references :product, type: :integer, index: true, null: false, foreign_key: { to_table: :spree_products }
      t.references :condition, index: true, null: false, foreign_key: { to_table: :solidus_promotions_conditions }

      t.timestamps
    end

    create_table :solidus_promotions_condition_taxons, force: :cascade do |t|
      t.references :taxon, type: :integer, index: true, null: false, foreign_key: { to_table: :spree_taxons }
      t.references :condition, index: true, null: false, foreign_key: { to_table: :solidus_promotions_conditions }

      t.timestamps
    end

    create_table :solidus_promotions_condition_users, force: :cascade do |t|
      t.references :user, type: :integer, index: true, null: false, foreign_key: { to_table: Spree.user_class.table_name }
      t.references :condition, index: true, null: false, foreign_key: { to_table: :solidus_promotions_conditions }

      t.timestamps
    end

    create_table :solidus_promotions_condition_stores do |t|
      t.references :store, type: :integer, index: true, null: false, foreign_key: { to_table: :spree_stores }
      t.references :condition, index: true, null: false, foreign_key: { to_table: :solidus_promotions_conditions }

      t.timestamps
    end
  end
end
