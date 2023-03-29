# frozen_string_literal: true

require "spree/migration"

class AddTimeRangeToTaxRate < Spree::Migration
  def change
    add_column :spree_tax_rates, :starts_at, :datetime
    add_column :spree_tax_rates, :expires_at, :datetime
  end
end
