# frozen_string_literal: true

class CreatePromotionCodeBatches < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_promotion_code_batches do |t|
      t.references :promotion, null: false, index: true, foreign_key: { to_table: :solidus_promotions_promotions }
      t.string :base_code, null: false
      t.integer :number_of_codes, null: false
      t.string :join_characters, null: false, default: "_"
      t.string :email
      t.string :error
      t.string :state, default: "pending"
      t.timestamps precision: 6
    end

    add_column(
      :solidus_promotions_promotion_codes,
      :promotion_code_batch_id,
      :bigint
    )

    add_foreign_key(
      :solidus_promotions_promotion_codes,
      :solidus_promotions_promotion_code_batches,
      column: :promotion_code_batch_id
    )

    add_index(
      :solidus_promotions_promotion_codes,
      :promotion_code_batch_id,
      name: "index_promotion_codes_on_promotion_code_batch_id"
    )
  end
end
