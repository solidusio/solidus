# frozen_string_literal: true

require 'rails/generators'
require 'bundler'
require 'bundler/cli'

module Solidus
  # @private
  class InstallGenerator < Rails::Generators::Base
    CORE_MOUNT_ROUTE = "mount Spree::Core::Engine"

    class_option :migrate, type: :boolean, default: true, banner: 'Run Solidus migrations'
    class_option :seed, type: :boolean, default: true, banner: 'load seed data (migrations must be run)'
    class_option :sample, type: :boolean, default: true, banner: 'load sample data (migrations must be run)'
    class_option :auto_accept, type: :boolean
    class_option :user_class, type: :string
    class_option :admin_email, type: :string
    class_option :admin_password, type: :string
    class_option :lib_name, type: :string, default: 'spree'
    class_option :with_authentication, type: :boolean, default: true
    class_option :enforce_available_locales, type: :boolean, default: nil

    def self.source_paths
      paths = superclass.source_paths
      paths << File.expand_path('../templates', "../../#{__FILE__}")
      paths << File.expand_path('../templates', "../#{__FILE__}")
      paths << File.expand_path('templates', __dir__)
      paths.flatten
    end

    def prepare_options
      @run_migrations = options[:migrate]
      @load_seed_data = options[:seed]
      @load_sample_data = options[:sample]

      unless @run_migrations
         @load_seed_data = false
         @load_sample_data = false
      end
    end

    def add_files
      template 'config/initializers/spree.rb.tt', 'config/initializers/spree.rb'
    end

    def additional_tweaks
      return unless File.exist? 'public/robots.txt'

      append_file "public/robots.txt", <<-ROBOTS.strip_heredoc
        User-agent: *
        Disallow: /checkout
        Disallow: /cart
        Disallow: /orders
        Disallow: /user
        Disallow: /account
        Disallow: /api
        Disallow: /password
      ROBOTS
    end

    def setup_assets
      @lib_name = 'spree'

      empty_directory 'app/assets/images'

      %w{javascripts stylesheets images}.each do |path|
        empty_directory "vendor/assets/#{path}/spree/frontend" if defined? Spree::Frontend || Rails.env.test?
        empty_directory "vendor/assets/#{path}/spree/backend" if defined? Spree::Backend || Rails.env.test?
      end

      if defined? Spree::Frontend || Rails.env.test?
        template "vendor/assets/javascripts/spree/frontend/all.js"
        template "vendor/assets/stylesheets/spree/frontend/all.css"
      end

      if defined? Spree::Backend || Rails.env.test?
        template "vendor/assets/javascripts/spree/backend/all.js"
        template "vendor/assets/stylesheets/spree/backend/all.css"
      end
    end

    def create_overrides_directory
      empty_directory "app/overrides"
    end

    def configure_application
      application <<-RUBY
    # Load application's model / class decorators
    initializer 'spree.decorators' do |app|
      config.to_prepare do
        Dir.glob(Rails.root.join('app/**/*_decorator*.rb')) do |path|
          require_dependency(path)
        end
      end
    end
      RUBY

      if !options[:enforce_available_locales].nil?
        application <<-RUBY
    # Prevent this deprecation message: https://github.com/svenfuchs/i18n/commit/3b6e56e
    I18n.enforce_available_locales = #{options[:enforce_available_locales]}
        RUBY
      end
    end

    def install_default_plugins
      if options[:with_authentication] && (options[:auto_accept] || yes?("
  Solidus has a default authentication extension that uses Devise.
  You can find more info at github.com/solidusio/solidus_auth_devise.

  Would you like to install it? (y/n)"))

        gem 'solidus_auth_devise'
      end
    end

    def include_seed_data
      append_file "db/seeds.rb", <<-RUBY.strip_heredoc

        Spree::Core::Engine.load_seed if defined?(Spree::Core)
        Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
      RUBY
    end

    def install_migrations
      say_status :copying, "migrations"
      `rake railties:install:migrations`
    end

    def create_database
      say_status :creating, "database"
      rake 'db:create'
    end

    def run_migrations
      if @run_migrations
        say_status :running, "migrations"

        rake 'db:migrate VERBOSE=false'
      else
        say_status :skipping, "migrations (don't forget to run rake db:migrate)"
      end
    end

    def populate_seed_data
      if @load_seed_data
        say_status :loading,  "seed data"
        rake_options = []
        rake_options << "AUTO_ACCEPT=1" if options[:auto_accept]
        rake_options << "ADMIN_EMAIL=#{options[:admin_email]}" if options[:admin_email]
        rake_options << "ADMIN_PASSWORD=#{options[:admin_password]}" if options[:admin_password]

        rake("db:seed #{rake_options.join(' ')}")
      else
        say_status :skipping, "seed data (you can always run rake db:seed)"
      end
    end

    def load_sample_data
      if @load_sample_data
        say_status :loading, "sample data"
        rake 'spree_sample:load'
      else
        say_status :skipping, "sample data (you can always run rake spree_sample:load)"
      end
    end

    def install_routes
      routes_file_path = File.join('config', 'routes.rb')
      unless File.read(routes_file_path).include? CORE_MOUNT_ROUTE
        insert_into_file routes_file_path, after: "Rails.application.routes.draw do\n" do
          <<-RUBY
  # This line mounts Solidus's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  #{CORE_MOUNT_ROUTE}, at: '/'

          RUBY
        end
      end

      unless options[:quiet]
        puts "*" * 50
        puts "We added the following line to your application's config/routes.rb file:"
        puts " "
        puts "    #{CORE_MOUNT_ROUTE}, at: '/'"
      end
    end

    def complete
      unless options[:quiet]
        puts "*" * 50
        puts "Solidus has been installed successfully. You're all ready to go!"
        puts " "
        puts "Enjoy!"
      end
    end
  end
end
