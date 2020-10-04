# frozen_string_literal: true

class RemoveCurrencyFromLineItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :spree_line_items, :currency, :string
  end
end
