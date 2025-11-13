# frozen_string_literal: true

class AddAmountLimitToPromotions < ActiveRecord::Migration[7.0]
  def change
    add_column :solidus_promotions_promotions, :amount_limit, :decimal, precision: 10, scale: 2, null: true
  end
end
