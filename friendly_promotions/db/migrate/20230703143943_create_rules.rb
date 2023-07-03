class CreateRules < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_friendly_promotions_rules do |t|
      t.references :promotion, foreign_key: { to_table: :solidus_friendly_promotions_promotions }
      t.string :type
      t.text :preferences

      t.timestamps
    end
  end
end
