# frozen_string_literal: true

class Spree::AddressForMigration < ActiveRecord::Base
  self.table_name = 'spree_addresses'
end

namespace 'solidus:migrations:migrate_address_names' do
  desc 'Backfills Spree::Address name attribute using firstname and lastname
    concatenation to keep historical data when upgrading to new address name
    format'
  task up: :environment do
    with_log do
      update_all(update_statement)
      if !ActiveRecord::Base.connection.index_exists?(:spree_addresses, :name)
        ActiveRecord::Base.connection.add_index(:spree_addresses, :name)
      end
    end
  end

  desc 'Reverts Spree::Address name attribute backfill'
  task down: :environment do
    with_log do
      if ActiveRecord::Base.connection.index_exists?(:spree_addresses, :name)
        ActiveRecord::Base.connection.remove_index(:spree_addresses, :name)
      end
      update_all('name = NULL')
    end
  end

  private

  def update_all(statement)
    Spree::AddressForMigration.in_batches do |addresses|
      addresses.update_all(statement)
    end
  end

  def update_statement
    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with?('sqlite')
      "name=(firstname || ' ' || lastname)"
    else
      "name=CONCAT(firstname, ' ', lastname)"
    end
  end

  def with_log
    puts "Updating #{Spree::Address.count} addresses"
    yield
    puts 'Addresses updated'
  end
end
