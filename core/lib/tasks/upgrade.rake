# frozen_string_literal: true

namespace :solidus do
  namespace :upgrade do
    desc "Upgrade Solidus to version 2.11.0"
    task two_point_eleven: [
        'solidus:migrations:migrate_default_billing_addresses_to_address_book:up'
      ] do
      puts "Your Solidus install is ready for Solidus 2.11.0"
    end
  end
end
