class CreateActions < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_friendly_promotions_actions do |t|
      t.references :promotion, index: true, null: false, foreign_key: { to_table: :solidus_friendly_promotions_promotions }
      t.string :type
      t.datetime :deleted_at, precision: nil
      t.text :preferences
      t.index [:deleted_at], name: :index_solidus_friendly_promotions_actions_on_deleted_at
      t.index [:id, :type], name: :index_solidus_friendly_promotions_actions_on_id_and_type

      t.timestamps
    end
  end
end
