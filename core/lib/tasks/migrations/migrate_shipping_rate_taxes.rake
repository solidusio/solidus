# frozen_string_literal: true

namespace :solidus do
  namespace :migrations do
    namespace :migrate_shipping_rate_taxes do
      task up: :environment do
        Spree::Deprecation.warn("rake spree:migrations:migrate_shipping_rate_taxes:up has been deprecated and will be removed with Solidus 3.0.")

        print "Adding persisted tax notes to historic shipping rates ... "
        Spree::ShippingRate.where.not(tax_rate_id: nil).find_each do |shipping_rate|
          tax_rate = Spree::TaxRate.unscoped.find(shipping_rate.tax_rate_id)
          shipping_rate.taxes.find_or_create_by!(
            tax_rate: tax_rate,
            amount: tax_rate.compute_amount(shipping_rate)
          )
        end
        Spree::ShippingRate.where.not(tax_rate_id: nil).update_all(tax_rate_id: nil)
        puts "Success."
      end
    end
  end
end
