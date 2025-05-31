# frozen_string_literal: true

class AddTaxReverseChargeModeToSpreeTaxCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_tax_categories, :tax_reverse_charge_mode, :integer, default: 0, null: false,
               comment: "Enum values: 0 = disabled, 1 = loose, 2 = strict"
  end
end
