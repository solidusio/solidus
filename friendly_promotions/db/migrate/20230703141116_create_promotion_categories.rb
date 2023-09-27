class CreatePromotionCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_promotion_categories do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    add_reference :friendly_promotions,
      :promotion_category,
      foreign_key: {to_table: :friendly_promotion_categories}
  end
end
