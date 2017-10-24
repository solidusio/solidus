
module DummyApp
  class AutoMigrate
    # Ensure database exists
    def database_exists?
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
    end

    def migrate
      if !database_exists? || ActiveRecord::Migrator.needs_migration?
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

ActiveRecord::Migrator.migrations_paths = Rails.application.migration_railties.flat_map do |engine|
  if engine.respond_to?(:paths)
    engine.paths['db/migrate'].to_a
  else
    []
  end
end

DummyApp::AutoMigrate.new.migrate
