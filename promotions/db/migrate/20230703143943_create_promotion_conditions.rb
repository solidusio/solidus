class CreatePromotionConditions < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_conditions do |t|
      t.references :benefit,
        foreign_key: {to_table: :solidus_promotions_benefits}
      t.string :type
      t.text :preferences

      t.timestamps
    end
  end
end
