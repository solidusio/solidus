class RemoveTaxRateFromShippingRate < ActiveRecord::Migration
  class Spree::ShippingRate < Spree::Base; end
  class Spree::TaxRate < Spree::Base
    has_one :calculator, class_name: "Spree::Calculator", as: :calculable, inverse_of: :calculable, dependent: :destroy, autosave: true
    def compute_amount(item)
      calculator.compute(item)
    end
  end

  def up
    say_with_time "Pre-calculating taxes for existing shipping rates" do
      Spree::ShippingRate.find_each do |shipping_rate|
        tax_rate_id = shipping_rate.tax_rate_id
        if tax_rate_id
          tax_rate = Spree::TaxRate.unscoped.find_by(shipping_rate.tax_rate_id)
          shipping_rate.taxes.create(
            tax_rate: tax_rate,
            amount: tax_rate.compute_amount(shipping_rate)
          )
        end
      end
    end

    remove_column :spree_shipping_rates, :tax_rate_id
  end

  def down
    add_reference :spree_shipping_rates, :tax_rate, index: true, foreign_key: true
    say_with_time "Attaching a tax rate to shipping rates" do
      Spree::ShippingRate.find_each do |shipping_rate|
        shipping_taxes = Spree::ShippingRateTax.where(shipping_rate_id: shipping_rate.id)
        # We can only use one tax rate, so let's take the biggest.
        selected_tax = shipping_taxes.sort_by(&:amount).last
        if selected_tax
          shipping_rate.update(tax_rate_id: tax_rate_id)
        end
      end
    end
  end
end
