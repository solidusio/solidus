# frozen_string_literal: true

class CreateCodeBatches < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_friendly_promotions_code_batches do |t|
      t.references :promotion, null: false, index: true, foreign_key: { to_table: :solidus_friendly_promotions_promotions }
      t.string :base_code, null: false
      t.integer :number_of_codes, null: false
      t.string :join_characters, null: false, default: "_"
      t.string :email
      t.string :error
      t.string :state, default: "pending"
      t.timestamps precision: 6
    end

    add_foreign_key(
      :solidus_friendly_promotions_code_batches,
      :solidus_friendly_promotions_promotions,
      column: :promotion_id
    )

    add_column(
      :solidus_friendly_promotions_codes,
      :code_batch_id,
      :integer
    )

    add_foreign_key(
      :solidus_friendly_promotions_codes,
      :solidus_friendly_promotions_code_batches,
      column: :code_batch_id
    )

    add_index(
      :solidus_friendly_promotions_codes,
      :code_batch_id
    )
  end
end
