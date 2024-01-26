# frozen_string_literal: true

class AddJoinCharactersToPromotionCodeBatch < ActiveRecord::Migration[5.1]
  def change
    add_column(:spree_promotion_code_batches,
               :join_characters,
               :string,
               null: false,
               default: '_')
  end
end
