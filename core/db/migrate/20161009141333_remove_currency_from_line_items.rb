# frozen_string_literal: true

require "spree/migration"

class RemoveCurrencyFromLineItems < Spree::Migration
  def change
    remove_column :spree_line_items, :currency, :string
  end
end
