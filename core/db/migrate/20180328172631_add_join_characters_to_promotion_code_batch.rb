# frozen_string_literal: true

require "spree/migration"

class AddJoinCharactersToPromotionCodeBatch < Spree::Migration
  def change
    add_column(:spree_promotion_code_batches,
               :join_characters,
               :string,
               null: false,
               default: '_')
  end
end
