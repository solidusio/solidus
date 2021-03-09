# frozen_string_literal: true

require 'thor'

namespace :solidus do
  namespace :migrations do
    namespace :migrate_address_names do
      desc 'Backfills Spree::Address name attribute using firstname and lastname
        concatenation in order to retain historical data when upgrading to new
        address name format'
      task up: :environment do
        puts "Combining addresses' firstname and lastname into name ... "
        class Spree::AddressForMigration < ApplicationRecord
          self.table_name = 'spree_addresses'
        end

        records = Spree::AddressForMigration.unscoped.where(name: [nil, ''])
        count = records.count
        connection = ActiveRecord::Base.connection
        adapter_name = connection.adapter_name.downcase
        shell = Thor::Shell::Basic.new
        puts "  Your DB contains #{count} addresses that may be affected by this task."
        # `trim` is not needed for pg or mysql when using `concat_ws`:
        # select concat_ws('joinstring', 'foo', null);
        #  concat_ws
        # -----------
        #  foo
        # (1 row)
        # select concat_ws('joinstring', 'foo', null) = trim(concat_ws('joinstring', 'foo', null));
        #  ?column?
        # ----------
        #  t
        # (1 row)
        unless count.zero?
          concat_statement = begin
            case adapter_name
            when /sqlite/
              "name = TRIM(COALESCE(firstname, '') || ' ' || COALESCE(lastname, ''))"
            when /postgres/, /mysql2/
              "name = CONCAT_WS(' ', firstname, lastname)"
            else
              abort "  No migration path available for adapter #{adapter_name}. Please write your own."
            end
          end

          # The batch size should be limited to avoid locking the table records for too long. These are
          # the numbers I got with 1_000_000 records in `spree_addresses`, all with different name and
          # surname, with postgresql:
          #
          # Updating 1000000 records in one shot
          # batch took 178 seconds
          #
          # Updating 1000000 addresses in batches of 200000
          # batch took 36 seconds
          # batch took 31 seconds
          # batch took 31 seconds
          # batch took 31 seconds
          # batch took 30 seconds
          #
          # Updating 1000000 addresses in batches of 150000
          # batch took 29 seconds
          # batch took 27 seconds
          # batch took 27 seconds
          # batch took 27 seconds
          # batch took 26 seconds
          # batch took 26 seconds
          # batch took 19 seconds
          #
          # Updating 1000000 addresses in batches of 100000
          # batch took 17 seconds
          # batch took 15 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          #
          # This is with mysql:
          # Updating 1000000 records in one shot
          # batch updated in 153 seconds
          #
          # Updating 1000000 records in batches of 200000, this may take a while...
          # batch took 41 seconds
          # batch took 37 seconds
          # batch took 35 seconds
          # batch took 28 seconds
          # batch took 27 seconds
          #
          # Updating 1000000 records in batches of 150000, this may take a while...
          # batch took 30 seconds
          # batch took 29 seconds
          # batch took 18 seconds
          # batch took 18 seconds
          # batch took 17 seconds
          # batch took 29 seconds
          # batch took 12 seconds
          #
          # Updating 1000000 records in batches of 100000, this may take a while...
          # batch took 10 seconds
          # batch took 11 seconds
          # batch took 12 seconds
          # batch took 13 seconds
          # batch took 12 seconds
          # batch took 12 seconds
          # batch took 14 seconds
          # batch took 19 seconds
          # batch took 20 seconds
          # batch took 21 seconds
          #
          # Please note that the migration will be much faster when there's no index
          # on the `name` column. For example, with mysql each batch takes exactly
          # the same time:
          #
          # Updating 1000000 records in batches of 200000, this may take a while...
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 17 seconds
          # batch took 16 seconds
          # batch took 17 seconds
          #
          # So, if special need arise, one can drop the index added with migration
          # 20210122110141_add_name_to_spree_addresses.rb and add the index later,
          # in non blocking ways. For postgresql:
          # add_index(:spree_addresses, :name, algorithm: :concurrently)
          #
          # For mysql 5.6:
          # sql = "ALTER TABLE spree_addresses ADD INDEX index_spree_addresses_on_name (name), ALGORITHM=INPLACE, LOCK=NONE;"
          # ActiveRecord::Base.connection.execute sql
          #
          puts '  Data migration will happen in batches. The default value is 100_000, which should take less than 20 seconds on mysql or postgresql.'
          size = shell.ask('  Please enter a different batch size, or press return to confirm the default: ')
          size = (size.presence || 100_000).to_i

          abort "  Invalid batch size number #{size}, please run the task again." unless size.positive?

          batches_total = (count / size).ceil
          puts "  We're going to migrate #{count} records in #{batches_total} batches of #{size}."

          answer = shell.ask('  Do you want to proceed?', limited_to: ['Y', 'N'], case_insensitive: true)
          if answer == 'Y'
            puts "  Updating #{count} records in batches of #{size}, this may take a while..."

            records.in_batches(of: size).each.with_index(1) do |batch, index|
              now = Time.zone.now
              batch.update_all(concat_statement)
              puts "  Batch #{index}/#{batches_total} done in #{(Time.zone.now - now).to_i} seconds."
            end
          else
            puts "  Database not migrated. Please, make sure to fill address's name field on your own."
          end
        end
      end
    end
  end
end
