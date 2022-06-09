# frozen_string_literal: true

unless defined?(Solidus::InstallGenerator)
  require 'generators/solidus/install/install_generator'
end

require 'generators/spree/dummy/dummy_generator'

class CommonRakeTasks
  include Rake::DSL

  def initialize
    namespace :common do
      task :test_app, :user_class do |_t, args|
        args.with_defaults(user_class: "Spree::LegacyUser")
        require ENV['LIB_NAME']

        ENV["RAILS_ENV"] = 'test'
        Rails.env = 'test'

        Spree::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]
        Solidus::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--with-authentication=false", "--payment-method=none", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=#{args[:user_class]}"]

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
