class CreatePromotionCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_friendly_promotions_promotion_categories do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    add_reference :solidus_friendly_promotions_promotions,
      :promotion_category,
      foreign_key: { to_table: :solidus_friendly_promotions_promotion_categories },
      index: { name: :index_solidus_friendly_promotions_promotions_categories }
  end
end
