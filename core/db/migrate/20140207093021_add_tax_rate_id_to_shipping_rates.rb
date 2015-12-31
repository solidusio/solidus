class AddTaxRateIdToShippingRates < ActiveRecord::Migration
  def change
    add_column :solidus_shipping_rates, :tax_rate_id, :integer
  end
end
