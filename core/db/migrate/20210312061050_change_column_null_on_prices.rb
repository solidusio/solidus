# frozen_string_literal: true

class ChangeColumnNullOnPrices < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:spree_prices, :amount, false)
  end
end
