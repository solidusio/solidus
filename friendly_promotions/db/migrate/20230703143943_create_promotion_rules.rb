class CreatePromotionRules < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_promotion_rules do |t|
      t.references :promotion,
        foreign_key: {to_table: :friendly_promotions}
      t.string :type
      t.text :preferences

      t.timestamps
    end
  end
end
