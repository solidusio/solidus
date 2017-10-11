task :dummy_environment do
  ENV['RAILS_ENV'] = 'test'
  ENV['VERBOSE'] = 'false'
  require 'spree/testing_support/dummy_app'
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
    ActiveRecord::Tasks::DatabaseTasks.migrate
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

  require 'rails/commands/console/console_command'
  Rails::Console.new(Rails.application, sandbox: true, environment: "test").start
end
