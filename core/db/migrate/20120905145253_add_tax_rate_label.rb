class AddTaxRateLabel < ActiveRecord::Migration
  def change
    add_column :solidus_tax_rates, :name, :string
  end
end
