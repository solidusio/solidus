# frozen_string_literal: true

class AddTimeRangeToTaxRate < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_tax_rates, :starts_at, :datetime
    add_column :spree_tax_rates, :expires_at, :datetime
  end
end
