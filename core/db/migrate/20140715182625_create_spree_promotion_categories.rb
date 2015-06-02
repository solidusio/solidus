class CreateSpreePromotionCategories < ActiveRecord::Migration
  def change
    create_table :spree_promotion_categories do |t|
      t.string :name
      t.timestamps null: true
    end

    add_column :spree_promotions, :promotion_category_id, :integer
    add_index :spree_promotions, :promotion_category_id
  end
end
