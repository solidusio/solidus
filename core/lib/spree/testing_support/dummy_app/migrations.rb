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
      !database_exists? || ActiveRecord::Migrator.needs_migration?
    end

    def auto_migrate
      if needs_migration?
        puts "Configuration changed. Re-running migrations"
        sh 'rake db:reset VERBOSE=false'

        # We might have a brand new database, so we must re-establish our connection
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
