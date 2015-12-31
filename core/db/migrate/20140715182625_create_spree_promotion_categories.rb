class CreateSpreePromotionCategories < ActiveRecord::Migration
  def change
    create_table :solidus_promotion_categories do |t|
      t.string :name
      t.timestamps null: true
    end

    add_column :solidus_promotions, :promotion_category_id, :integer
    add_index :solidus_promotions, :promotion_category_id
  end
end
