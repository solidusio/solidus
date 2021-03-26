# frozen_string_literal: true

class AddCurrenciesToStores < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_stores, :currencies, :text
  end
end
