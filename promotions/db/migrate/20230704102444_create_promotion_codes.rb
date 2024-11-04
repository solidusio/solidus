class CreatePromotionCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_promotion_codes, force: :cascade do |t|
      t.references :promotion, null: false, index: true, foreign_key: { to_table: :solidus_promotions_promotions }
      t.string :value, null: false
      t.timestamps

      t.index ["value"], name: "index_solidus_promotions_promotion_codes_on_value", unique: true
    end
  end
end
