# frozen_string_literal: true

require "spree/migration"

class AddAvailableLocalesToStores < Spree::Migration
  def change
    change_table :spree_stores do |t|
      t.column :available_locales, :string
    end
  end
end
