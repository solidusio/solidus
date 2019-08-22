# frozen_string_literal: true

module DummyApp
  class RakeTasks
    include Rake::DSL

    def initialize(gem_root:, lib_name:)
      task :dummy_environment do
        ENV['RAILS_ENV'] = 'test'
        require lib_name
        require 'spree/testing_support/dummy_app'
        DummyApp.setup(
          gem_root: gem_root,
          lib_name: lib_name,
          auto_migrate: false
        )
      end
    end
  end
end

namespace :db do
  desc "Drops the test database"
  task drop: :dummy_environment do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  desc "Creates the test database"
  task create: :dummy_environment do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  desc "Migrates the test database"
  task migrate: :dummy_environment do
    ActiveRecord::Migration.verbose = false

    # We want to simulate how migrations would be run if a user ran
    # railties:install:migrations and then db:migrate.
    # Migrations should be run one directory at a time
    ActiveRecord::Migrator.migrations_paths.each do |path|
      if Rails.gem_version >= Gem::Version.new('6.0.0')
        ActiveRecord::MigrationContext.new(
          [path],
          ActiveRecord::SchemaMigration
        ).migrate
      elsif Rails.gem_version >= Gem::Version.new('5.2.0')
        ActiveRecord::MigrationContext.new([path]).migrate
      else
        ActiveRecord::Migrator.migrate(path)
      end
    end

    ActiveRecord::Base.clear_cache!
  end

  desc "Recreates the test database and re-runs all migrations"
  task reset: ['db:drop', 'db:create', 'db:migrate']
end

desc "Open a sandboxed console in the test environment"
task console: :dummy_environment do
  begin
    require 'pry'
    Rails.application.config.console = Pry
  rescue LoadError
  end

  require 'rails/commands'
  require 'rails/commands/console/console_command'
  Rails::Console.new(Rails.application, sandbox: true, environment: "test").start
end
