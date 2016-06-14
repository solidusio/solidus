namespace :solidus do
  namespace :migrations do
    namespace :create_vat_prices do
      task up: :environment do
        print "Creating differentiated prices for VAT countries ... "
        if Spree::Zone.default_tax
          Spree::PriceMigrator.migrate_default_vat_prices
          puts "Success."
        else
          puts "No Zone set as default_tax. Skipping."
        end
      end
    end
  end
end
