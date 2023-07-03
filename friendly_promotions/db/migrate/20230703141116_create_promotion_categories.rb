class CreatePromotionCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_friendly_promotions_categories do |t|
      t.string :name

      t.timestamps
    end

    add_reference :solidus_friendly_promotions_promotions, :category, foreign_key: { to_table: :solidus_friendly_promotions_categories }
  end
end
