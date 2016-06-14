namespace :solidus do
  namespace :migrations do
    namespace :migrate_shipping_rate_taxes do
      task up: :environment do
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
