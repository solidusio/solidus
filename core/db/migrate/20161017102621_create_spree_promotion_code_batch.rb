# frozen_string_literal: true

class CreateSpreePromotionCodeBatch < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_promotion_code_batches do |t|
      t.references :promotion, null: false, index: true
      t.string :base_code, null: false
      t.integer :number_of_codes, null: false
      t.string :email
      t.string :error
      t.string :state, default: "pending"
      t.timestamps precision: 6
    end

    add_foreign_key(
      :spree_promotion_code_batches,
      :spree_promotions,
      column: :promotion_id
    )

    add_column(
      :spree_promotion_codes,
      :promotion_code_batch_id,
      :integer
    )

    add_foreign_key(
      :spree_promotion_codes,
      :spree_promotion_code_batches,
      column: :promotion_code_batch_id
    )

    add_index(
      :spree_promotion_codes,
      :promotion_code_batch_id
    )
  end
end
