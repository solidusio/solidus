# frozen_string_literal: true

class ChangeCountriesIsoToUnique < ActiveRecord::Migration[7.0]
  def change
    remove_index :spree_countries, :iso

    add_index :spree_countries, :iso, unique: true
  end
end
