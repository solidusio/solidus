# frozen_string_literal: true

namespace :solidus do
  namespace :upgrade do
    desc "Upgrade Solidus to version 2.11"
    task two_point_eleven: [
        'solidus:migrations:migrate_default_billing_addresses_to_address_book:up',
        'solidus:migrations:migrate_address_names:up'
      ] do
      puts "Your Solidus install is ready for Solidus 2.11"
    end

    desc "Upgrade Solidus to version 3.0"
    task three_point_zero: [
        'solidus:migrations:delete_prices_with_nul_amount:up',
      ] do
      puts "Your Solidus install is ready for Solidus 3.0"
    end
  end
end
