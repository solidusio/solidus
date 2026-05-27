# frozen_string_literal: true

# Mutant hooks (see core/.mutant.yml).
#
# Per the mutant Rails guide (docs/rails.md), parallel workers must each get
# their own database or they corrupt each other's fixtures. This is the
# PostgreSQL pattern: each worker clones the migrated test database via
# `CREATE DATABASE ... TEMPLATE`, named "<db>_mutant_worker_<index>".
#
# The guide's `with_root_connection` uses `ActiveRecord::Base.postgresql_connection`,
# which was removed in Rails 8.x; we open the maintenance connection with the pg
# gem directly instead. The rest follows the guide.
require "pg"

# Eager load so subjects are discoverable (Zeitwerk lazy-loads otherwise).
hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end

# Disconnect the parent before workers clone the template database.
hooks.register(:setup_integration_post) do
  base_records.each do |base|
    disconnect_pool(base:)
  end
end

# Both registrations are required to isolate in both modes:
# mutation_worker_process_start for `mutant run`, test_worker_process_start for `mutant test`.
hooks.register(:test_worker_process_start)     { |index:| isolate_index(index:) }
hooks.register(:mutation_worker_process_start) { |index:| isolate_index(index:) }

def self.base_records
  [
    ActiveRecord::Base,
  ]
end

def self.isolate_index(index:)
  base_records.each do |base|
    disconnect_pool(base:)
    isolate_database(base:, index:)
  end
end

def self.isolate_database(base:, index:)
  db_config = base
    .connection_handler
    .retrieve_connection_pool(base.connection_specification_name)
    .db_config

  raw_template_database = db_config.database
  raw_isolated_database = "#{raw_template_database}_mutant_worker_#{index}"

  with_root_connection do |connection|
    template_database = PG::Connection.quote_ident(raw_template_database)
    isolated_database = PG::Connection.quote_ident(raw_isolated_database)

    connection.exec("DROP DATABASE IF EXISTS #{isolated_database}")
    connection.exec("CREATE DATABASE #{isolated_database} TEMPLATE #{template_database}")
  end

  db_config._database = raw_isolated_database
end

def self.disconnect_pool(base:)
  base
    .connection_handler
    .retrieve_connection_pool(base.connection_specification_name)
    .disconnect
end

# Open a connection to the "postgres" maintenance database so we can issue
# CREATE/DROP DATABASE. (Replaces the guide's removed Base.postgresql_connection.)
def self.with_root_connection
  base = ActiveRecord::Base

  config = base
    .connection_handler
    .retrieve_connection_pool(base.connection_specification_name)
    .db_config
    .configuration_hash

  connection = PG.connect(
    host:     config[:host],
    port:     config[:port] || 5432,
    user:     config[:username],
    password: config[:password],
    dbname:   "postgres"
  )

  yield connection
ensure
  connection&.close
end
