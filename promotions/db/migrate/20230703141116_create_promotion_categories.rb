class CreatePromotionCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_promotion_categories do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    add_reference :solidus_promotions_promotions,
      :promotion_category,
      foreign_key: { to_table: :solidus_promotions_promotion_categories }
  end
end
