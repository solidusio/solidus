class CreatePromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_promotions do |t|
      t.string :description
      t.datetime :expires_at, precision: nil
      t.datetime :starts_at, precision: nil
      t.string :name
      t.integer :usage_limit
      t.boolean :advertise, default: false
      t.string :path
      t.integer :per_code_usage_limit
      t.boolean :apply_automatically, default: false
      t.timestamps
    end
  end
end
