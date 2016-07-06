namespace :solidus do
  namespace :upgrade do
    desc "Upgrade Solidus to version 1.3"
    task one_point_three: [
        'solidus:migrations:migrate_shipping_rate_taxes:up',
        'solidus:migrations:create_vat_prices:up'
      ] do
      puts "Your Solidus install is ready for Solidus 1.3."
    end
  end
end
