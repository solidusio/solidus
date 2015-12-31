class CreateSpreePromotionCodes < ActiveRecord::Migration
  def change
    create_table :solidus_promotion_codes do |t|
      t.references :promotion, index: true, null: false
      t.string :value, null: false
      t.integer :usage_limit

      t.timestamps null: true
    end

    add_index :solidus_promotion_codes, :value, unique: true
  end
end
