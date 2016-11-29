unless defined?(Spree::InstallGenerator)
  require 'generators/spree/install/install_generator'
end

require 'generators/spree/dummy/dummy_generator'

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app, :user_class do |_t, args|
    args.with_defaults(user_class: "Spree::LegacyUser")
    require ENV['LIB_NAME']

    ENV["RAILS_ENV"] = 'test'

    Spree::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]
    Spree::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=#{args[:user_class]}"]

    puts "Setting up dummy database..."

    sh "bundle exec rake db:drop db:create db:migrate VERBOSE=false"

    begin
      require "generators/#{ENV['LIB_NAME']}/install/install_generator"
      puts 'Running extension installation generator...'
      "#{ENV['LIB_NAME'].camelize}::Generators::InstallGenerator".constantize.start(["--auto-run-migrations"])
    rescue LoadError
      # No extension generator to run
    end
  end

  task :seed do |_t, _args|
    puts "Seeding ..."

    sh "bundle exec rake db:seed RAILS_ENV=test"
  end
end
