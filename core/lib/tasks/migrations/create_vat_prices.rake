namespace :solidus do
  namespace :migrations do
    namespace :create_vat_prices do
      task up: :environment do
        print "Creating differentiated prices for VAT countries ... "
        Spree::PriceMigrator.migrate_default_vat_prices
        puts "Success."
      end
    end
  end
end
