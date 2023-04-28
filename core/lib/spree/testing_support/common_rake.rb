# frozen_string_literal: true

require 'generators/spree/dummy/dummy_generator'

class CommonRakeTasks
  include Rake::DSL

  def initialize
    namespace :common do
      task :test_app, :user_class do |_t, args|
        args.with_defaults(user_class: "Spree::LegacyUser")
        lib_name = ENV['LIB_NAME'] or
          raise "Please provide a library name via the LIB_NAME environment variable."

        require lib_name

        force_rails_environment_to_test

        Spree::DummyGenerator.start [
          "--lib-name=#{lib_name}",
          "--quiet",
        ]

        # While the dummy app is generated the current directory
        # within ruby is changed to that of the dummy app.
        sh({
          'FRONTEND' => ENV['FRONTEND'] || 'none',
        }, [
          'bin/rails',
          'generate',
          'solidus:install',
          Dir.pwd, # use the current dir as Rails.root
          "--auto-accept",
          "--authentication=none",
          "--payment-method=none",
          "--migrate=false",
          "--seed=false",
          "--sample=false",
          "--user-class=#{args[:user_class]}",
          "--quiet",
        ].shelljoin)

        if Bundler.locked_gems.dependencies['solidus_frontend']
          sh "bin/rails g solidus_frontend:install --auto-accept"
        end

        puts "Setting up dummy database..."

        sh "bin/rails db:environment:set RAILS_ENV=test"
        sh "bin/rails db:drop db:create db:migrate VERBOSE=false RAILS_ENV=test"

        if extension_installation_generator_exists?
          puts 'Running extension installation generator...'
          sh "bin/rails generate #{rake_generator_namespace}:install --auto-run-migrations"
        end
      end

      task :seed do |_t, _args|
        puts "Seeding ..."

        sh "bundle exec rake db:seed RAILS_ENV=test"
      end
    end
  end

  private

  def force_rails_environment_to_test
    ENV["RAILS_ENV"] = 'test'
    Rails.env = 'test'
  end

  def extension_installation_generator_exists?
    require "generators/#{generator_namespace}/install/install_generator"

    true
  rescue LoadError
    false
  end

  def generator_namespace
    "#{ENV['LIB_NAMESPACE']&.underscore || ENV['LIB_NAME']}"
  end

  def rake_generator_namespace
    generator_namespace.gsub("/", ":")
  end
end

CommonRakeTasks.new
