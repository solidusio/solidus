unless defined?(Solidus::InstallGenerator)
  require 'generators/spree/install/install_generator'
end

require 'generators/spree/dummy/dummy_generator'

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app, :user_class do |t, args|
    args.with_defaults(:user_class => "Solidus::LegacyUser")
    require "#{ENV['LIB_NAME']}"

    ENV["RAILS_ENV"] = 'test'

    Solidus::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]
    Solidus::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=#{args[:user_class]}"]

    puts "Setting up dummy database..."

    silence_stream(STDOUT) do
      sh "bundle exec rake db:drop db:create db:migrate"
    end

    begin
      require "generators/#{ENV['LIB_NAME']}/install/install_generator"
      puts 'Running extension installation generator...'
      "#{ENV['LIB_NAME'].camelize}::Generators::InstallGenerator".constantize.start(["--auto-run-migrations"])
    rescue LoadError
      puts 'Skipping installation no generator to run...'
    end
  end

  task :seed do |t, args|
    puts "Seeding ..."

    silence_stream(STDOUT) do
      sh "bundle exec rake db:seed RAILS_ENV=test"
    end
  end
end
