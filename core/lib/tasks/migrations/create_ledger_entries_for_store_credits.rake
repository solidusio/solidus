namespace :solidus do
  namespace :migrations do
    namespace :create_ledger_entries_for_store_credits do
      task up: :environment do
        # invalidated store credits
        # create ledger entry with 0.0 amount
        ActiveRecord::Base.connection.execute <<-SQL
        INSERT INTO spree_store_credit_ledger_entries
          (store_credit_id, amount, created_at, updated_at)
          SELECT id, 0, '#{Time.current.to_s(:db)}', '#{Time.current.to_s(:db)}'
          FROM spree_store_credits
          WHERE invalidated_at IS NOT NULL
        SQL

        # store_credits in use will have a liabilty ledger entry
        # with an amount that is the store_credit amount minus the used
        # store_credits
        ActiveRecord::Base.connection.execute <<-SQL
        INSERT INTO spree_store_credit_ledger_entries
          (store_credit_id, amount, created_at, updated_at)
          SELECT id, amount - amount_used, '#{Time.current.to_s(:db)}', '#{Time.current.to_s(:db)}'
          FROM spree_store_credits
          WHERE invalidated_at IS NULL
        SQL

        # the store_credits with amount_authorized available will need
        # to have a 'pending' ledger entry created
        ActiveRecord::Base.connection.execute <<-SQL
        INSERT INTO spree_store_credit_ledger_entries
          (store_credit_id, amount, liability, created_at, updated_at)
          SELECT id, amount_authorized, 'f', '#{Time.current.to_s(:db)}', '#{Time.current.to_s(:db)}'
          FROM spree_store_credits
          WHERE invalidated_at IS NULL AND amount_authorized > 0.0
        SQL
      end

      task down: :environment do
        Spree::StoreCreditLedgerEntry.delete_all
      end
    end
  end
end
