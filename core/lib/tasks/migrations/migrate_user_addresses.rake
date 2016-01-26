namespace 'spree:migrations:migrate_user_addresses' do
  # This creates an entry in the user_addresses table for a user's currently
  # associated shipping and billing addresses.

  # This task should not need to be run more than once. But the de-dup behavior in
  # UserAddressBook should make it safe.
  # When the code (in the same PR) is deployed, each new order's addresses will be added
  # to the user's address book. This will catch up all the historical data.

  task up: :environment do
    Spree.user_class.find_each(batch_size: 500) do |user|
      ship_address = Spree::Address.find_by_id(user.ship_address_id)
      bill_address = Spree::Address.find_by_id(user.bill_address_id)

      current_addresses = [bill_address, ship_address].compact.uniq

      current_addresses.each do |address|
        # since ship_address is last, it will override bill_address as default when both are present
        user.save_in_address_book(address.attributes, true)
      end

      puts "Migrated addresses for user ##{user.id}"
    end
  end

  task down: :environment do
    Spree::UserAddress.delete_all
  end
end
