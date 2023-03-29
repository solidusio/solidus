# frozen_string_literal: true

require "spree/migration"

class ChangeColumnNullOnPrices < Spree::Migration
  def change
    change_column_null(:spree_prices, :amount, false)
  end
end
