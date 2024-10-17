# frozen_string_literal: true

module DummyApp
  module Migrations
    extend self

    def auto_migrate
      if needs_migration?
        puts "Configuration changed. Re-running migrations"

        # Disconnect to avoid "database is being accessed by other users" on postgres
        ActiveRecord::Base.remove_connection

        sh 'rake db:reset VERBOSE=false'

        # We have a brand new database, so we must re-establish our connection
        ActiveRecord::Base.establish_connection
      end
    end

    private

    def needs_migration?
      ActiveRecord::Migration.check_all_pending!
    rescue ActiveRecord::PendingMigrationError, ActiveRecord::NoDatabaseError
      true
    else
      false
    end

    def sh(cmd)
      puts cmd
      system cmd
    end
  end
end
