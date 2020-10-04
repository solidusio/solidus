# frozen_string_literal: true

module DummyApp
  module Migrations
    extend self

    # Ensure database exists
    def database_exists?
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
    end

    def needs_migration?
      return true if !database_exists?

      ActiveRecord::Base.connection.migration_context.needs_migration?
    end

    def auto_migrate
      if needs_migration?
        puts "Configuration changed. Re-running migrations"

        # Disconnect to avoid "database is being accessed by other users" on postgres
        ActiveRecord::Base.remove_connection

        sh 'rake db:reset VERBOSE=false'
        if ENV['ENABLE_ACTIVE_STORAGE']
          sh 'rake active_storage:install db:migrate VERBOSE=false'
        end

        # We have a brand new database, so we must re-establish our connection
        ActiveRecord::Base.establish_connection
      end
    end

    private

    def sh(cmd)
      puts cmd
      system cmd
    end
  end
end
