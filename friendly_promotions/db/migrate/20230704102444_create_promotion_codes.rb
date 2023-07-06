class CreatePromotionCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_promotion_codes, force: :cascade do |t|
      t.references :promotion, null: false, index: true, foreign_key: { to_table: :friendly_promotions }
      t.string :value, null: false
      t.timestamps

      t.index ["value"], name: "index_friendly_promotion_codes_on_value", unique: true
    end
  end
end
