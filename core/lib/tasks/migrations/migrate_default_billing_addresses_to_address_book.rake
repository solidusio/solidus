# frozen_string_literal: true

namespace :solidus do
  namespace :migrations do
    namespace :migrate_default_billing_addresses_to_address_book do
      task up: :environment do
        print "Migrating default billing addresses to address book ... "
        if Spree::UserAddress.where(default_billing: true).any?
          Spree.user_class.joins(:bill_address).update_all(bill_address_id: nil) # rubocop:disable Rails/SkipsModelValidations
        end
        adapter_type = Spree::Base.connection.adapter_name.downcase.to_sym
        if adapter_type == :mysql2
          sql = <<~SQL
            UPDATE spree_user_addresses
            JOIN spree_users ON spree_user_addresses.user_id = spree_users.id
              AND spree_user_addresses.address_id = spree_users.bill_address_id
            SET spree_user_addresses.default_billing = true
          SQL
        else
          sql = <<~SQL
            UPDATE spree_user_addresses
            SET default_billing = true
            FROM spree_users
            WHERE spree_user_addresses.address_id = spree_users.bill_address_id
              AND spree_user_addresses.user_id = spree_users.id;
          SQL
        end
        Spree::Base.connection.execute sql
        puts "Success"
      end

      task down: :environment do
        Spree::UserAddress.update_all(default_billing: false) # rubocop:disable Rails/SkipsModelValidations
        puts "Rolled back default billing address migration to address book"
      end
    end
  end
end
