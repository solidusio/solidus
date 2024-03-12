# frozen_string_literal: true

class CreateSpreePromotionCodeBatch < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_promotion_code_batches, if_not_exists: true do |t|
      t.references :promotion, null: false, index: true, type: :bigint
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
      column: :promotion_id,
      if_not_exists: true
    )

    add_column(
      :spree_promotion_codes,
      :promotion_code_batch_id,
      :bigint,
      if_not_exists: true
    )

    add_foreign_key(
      :spree_promotion_codes,
      :spree_promotion_code_batches,
      column: :promotion_code_batch_id,
      if_not_exists: true
    )

    add_index(
      :spree_promotion_codes,
      :promotion_code_batch_id,
      if_not_exists: true
    )
  end
end
