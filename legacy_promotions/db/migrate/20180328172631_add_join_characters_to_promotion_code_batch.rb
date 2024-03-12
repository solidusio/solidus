# frozen_string_literal: true

class AddJoinCharactersToPromotionCodeBatch < ActiveRecord::Migration[6.1]
  def change
    add_column(
      :spree_promotion_code_batches,
      :join_characters,
      :string,
      null: false,
      default: "_",
      if_not_exists: true
    )
  end
end
