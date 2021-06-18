# frozen_string_literal: true

namespace :solidus do
  namespace :migrations do
    namespace :migrate_default_billing_addresses_to_address_book do
      task :up, [:batch_size] => [:environment] do |_t, args|
        batch_size = args[:batch_size] || 100_000
        print "Migrating default billing addresses to address book in batches of #{batch_size} ... "
        if Spree::UserAddress.where(default_billing: true).any?
          Spree.user_class.joins(:bill_address).in_batches(of: batch_size).each do |batch|
            batch.update_all(bill_address_id: nil) # rubocop:disable Rails/SkipsModelValidations
          end
        end
        Spree::UserAddress.joins(
          <<~SQL
            JOIN spree_users ON spree_user_addresses.user_id = spree_users.id
                             AND spree_user_addresses.address_id = spree_users.bill_address_id
          SQL
        ).in_batches(of: batch_size).each do |batch|
          batch.update_all(default_billing: true) # rubocop:disable Rails/SkipsModelValidations
        end

        puts "Success"
      end

      task :down, [:batch_size] => [:environment] do |_t, args|
        batch_size = args[:batch_size] || 100_000
        Spree::UserAddress.in_batches(of: batch_size).update_all(default_billing: false) # rubocop:disable Rails/SkipsModelValidations
        puts "Rolled back default billing address migration to address book"
      end
    end
  end
end
