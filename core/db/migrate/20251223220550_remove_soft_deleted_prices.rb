# frozen_string_literal: true

class RemoveSoftDeletedPrices < ActiveRecord::Migration[7.0]
  def up
    discarded_prices = Spree::Price.where.not(deleted_at: nil)
    affected_variant_ids = discarded_prices.map(&:variant_id).uniq
    discarded_prices.delete_all
    Spree::Variant.where(id: affected_variant_ids).find_each(&:touch)
    remove_column :spree_prices, :deleted_at
  end

  def down
    add_column :spree_prices, :deleted_at, :timestamp, null: true
  end
end
