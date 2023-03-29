# frozen_string_literal: true

require "spree/migration"

class RemoveIsDefaultFromPrices < Spree::Migration
  def change
    remove_column :spree_prices, :is_default, :boolean, default: true
  end
end
