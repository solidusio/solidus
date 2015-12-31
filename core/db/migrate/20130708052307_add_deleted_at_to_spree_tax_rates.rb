class AddDeletedAtToSpreeTaxRates < ActiveRecord::Migration
  def change
    add_column :solidus_tax_rates, :deleted_at, :datetime
  end
end
