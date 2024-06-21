# frozen_string_literal: true

class CreateSpreePromotionCodeBatch < ActiveRecord::Migration[5.0]
  def change
    unless table_exists?(:spree_promotion_code_batches)
      create_table :spree_promotion_code_batches do |t|
        t.references :promotion, null: false, index: true, type: :integer
        t.string :base_code, null: false
        t.integer :number_of_codes, null: false
        t.string :email
        t.string :error
        t.string :state, default: "pending"
        t.timestamps precision: 6
      end
    end

    unless foreign_key_exists?(:spree_promotion_code_batches, :spree_promotions)
      add_foreign_key(
        :spree_promotion_code_batches,
        :spree_promotions,
        column: :promotion_id
      )
    end

    unless column_exists?(:spree_promotion_codes, :promotion_code_batch_id)
      add_column(
        :spree_promotion_codes,
        :promotion_code_batch_id,
        :integer,
      )
    end

    unless foreign_key_exists?(:spree_promotion_codes, :spree_promotion_code_batches)
      add_foreign_key(
        :spree_promotion_codes,
        :spree_promotion_code_batches,
        column: :promotion_code_batch_id,
      )
    end

    unless index_exists?(:spree_promotion_codes, :promotion_code_batch_id)
      add_index(
        :spree_promotion_codes,
        :promotion_code_batch_id,
      )
    end
  end
end
