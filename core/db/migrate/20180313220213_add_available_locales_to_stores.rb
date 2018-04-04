# frozen_string_literal: true

class AddAvailableLocalesToStores < ActiveRecord::Migration[5.1]
  def change
    change_table :spree_stores do |t|
      t.column :available_locales, :string
    end
  end
end
