# frozen_string_literal: true

class CreatePromotionCodeBatches < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_promotion_code_batches do |t|
      t.references :promotion, null: false, index: true, foreign_key: { to_table: :friendly_promotions }
      t.string :base_code, null: false
      t.integer :number_of_codes, null: false
      t.string :join_characters, null: false, default: "_"
      t.string :email
      t.string :error
      t.string :state, default: "pending"
      t.timestamps precision: 6
    end

    add_column(
      :friendly_promotion_codes,
      :promotion_code_batch_id,
      :bigint
    )

    add_foreign_key(
      :friendly_promotion_codes,
      :friendly_promotion_code_batches,
      column: :promotion_code_batch_id
    )

    add_index(
      :friendly_promotion_codes,
      :promotion_code_batch_id
    )
  end
end
