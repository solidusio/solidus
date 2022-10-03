# frozen_string_literal: true

require 'rails/version'
require 'rails/generators'
require 'rails/generators/app_base'

module Solidus
  # @private
  class InstallGenerator < Rails::Generators::AppBase
    argument :app_path, type: :string, default: Rails.root

    CORE_MOUNT_ROUTE = "mount Spree::Core::Engine"

    LEGACY_FRONTEND = 'solidus_frontend'
    DEFAULT_FRONTEND = 'solidus_starter_frontend'
    FRONTENDS = {
      'none' => "#{__dir__}/app_templates/frontend/none.rb",
      'solidus_frontend' => "#{__dir__}/app_templates/frontend/solidus_frontend.rb",
      'solidus_starter_frontend' => "#{__dir__}/app_templates/frontend/solidus_starter_frontend.rb",
    }

    DEFAULT_AUTHENTICATION = 'devise'
    AUTHENTICATIONS = {
      'devise' => "#{__dir__}/app_templates/authentication/devise.rb",
      'existing' => "#{__dir__}/app_templates/authentication/existing.rb",
      'custom' => "#{__dir__}/app_templates/authentication/custom.rb",
      'none' => "#{__dir__}/app_templates/authentication/none.rb",
    }

    class_option :migrate, type: :boolean, default: true, banner: 'Run Solidus migrations'
    class_option :seed, type: :boolean, default: true, banner: 'Load seed data (migrations must be run)'
    class_option :sample, type: :boolean, default: true, banner: 'Load sample data (migrations must be run)'
    class_option :active_storage, type: :boolean, default: (
      Rails.gem_version >= Gem::Version.new("6.1.0")
    ), banner: 'Install ActiveStorage as image attachments handler for products and taxons'
    class_option :auto_accept, type: :boolean
    class_option :user_class, type: :string
    class_option :admin_email, type: :string
    class_option :admin_password, type: :string
    class_option :frontend, type: :string, enum: FRONTENDS.keys, default: nil, desc: "Indicates which frontend to install."
    class_option :authentication, type: :string, enum: AUTHENTICATIONS.keys, default: nil, desc: "Indicates which authentication system to install."

    # DEPRECATED
    class_option :with_authentication, type: :boolean, hide: true, default: nil
    class_option :enforce_available_locales, type: :boolean, hide: true, default: nil
    class_option :lib_name, type: :string, hide: true, default: nil

    def self.source_paths
      paths = superclass.source_paths
      paths << File.expand_path('../templates', "../../#{__FILE__}")
      paths << File.expand_path('../templates', "../#{__FILE__}")
      paths << File.expand_path('templates', __dir__)
      paths.flatten
    end

    def self.exit_on_failure?
      true
    end

    def prepare_options
      @run_migrations = options[:migrate]
      @load_seed_data = options[:seed]
      @load_sample_data = options[:sample]

      # Silence verbose output (e.g. Rails migrations will rely on this environment variable)
      ENV['VERBOSE'] = 'false'

      # No reason to check for their presence if we're about to install them
      ENV['SOLIDUS_SKIP_MIGRATIONS_CHECK'] = 'true'

      if options[:with_authentication] != nil
        warn \
          "DEPRECATION WARNING: using `solidus:install --with-authentication` is now deprecated. " \
          "Please use --authentication instead (see --help for the full list of options)."

        if options[:authentication].blank? && options[:with_authentication] == 'false'
          # Don't use the default authentication if the user explicitly
          # requested no authentication system.
          options[:authentication] = 'none'
        end
      end

      if options[:enforce_available_locales] != nil
        warn \
          "DEPRECATION WARNING: using `solidus:install --enforce-available-locales` is now deprecated and has no effect. " \
          "Since Rails 4.1 the default is `true` so we no longer need to explicitly set a value."
      end

      if options[:lib_name] != nil
        warn \
          "DEPRECATION WARNING: using `solidus:install --lib-name` is now deprecated and has no effect. " \
          "The option is legacy and should be removed from scripts still using it."
      end

      unless @run_migrations
        @load_seed_data = false
        @load_sample_data = false
      end
    end

    def add_files
      template 'config/initializers/spree.rb.tt', 'config/initializers/spree.rb'
    end

    def install_file_attachment
      if options[:active_storage]
        say_status :assets, "Active Storage", :green
        rake 'active_storage:install'
      else
        say_status :assets, "Paperclip", :green
        gsub_file 'config/initializers/spree.rb', "ActiveStorageAttachment", "PaperclipAttachment"
      end
    end

    def setup_assets
      empty_directory 'app/assets/images'

      %w{javascripts stylesheets images}.each do |path|
        empty_directory "vendor/assets/#{path}/spree/backend" if defined?(Spree::Backend) || Rails.env.test?
      end

      if defined?(Spree::Backend) || Rails.env.test?
        template "vendor/assets/javascripts/spree/backend/all.js"
        template "vendor/assets/stylesheets/spree/backend/all.css"
      end
    end

    def create_overrides_directory
      empty_directory "app/overrides"
    end

    def include_seed_data
      append_file "db/seeds.rb", <<~RUBY

        Spree::Core::Engine.load_seed if defined?(Spree::Core)
        Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
      RUBY
    end

    def install_migrations
      say_status :copying, "migrations"
      rake 'railties:install:migrations'
    end

    def create_database
      say_status :creating, "database"
      rake 'db:create'
    end

    def install_authentication
      authentication_key = detect_authentication_to_install

      authentication_template = AUTHENTICATIONS.fetch(authentication_key.presence) do
        say_status :warning, "Unknown authentication: #{authentication_key.inspect}, attempting to run it with `rails app:template`"
        authentication_key
      end

      say_status :auth, authentication_key

      apply authentication_template
    end

    def install_routes
      if Pathname(app_path).join('config', 'routes.rb').read.include? CORE_MOUNT_ROUTE
        say_status :route_exist, CORE_MOUNT_ROUTE, :blue
      else
        route <<~RUBY
          # This line mounts Solidus's routes at the root of your application.
          # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
          # If you would like to change where this engine is mounted, simply change the :at option to something different.
          #
          # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
          #{CORE_MOUNT_ROUTE}, at: '/'
        RUBY
      end
    end

    def install_frontend
      frontend_key = detect_frontend_to_install

      frontend_template = FRONTENDS.fetch(frontend_key.presence) do
        say_status :warning, "Unknown frontend: #{frontend_key.inspect}, attempting to run it with `rails app:template`"
        frontend_key
      end

      say_status :frontend, frontend_key

      apply frontend_template
    end

    def run_migrations
      if @run_migrations
        say_status :running, "migrations"

        rake 'db:migrate'
      else
        say_status :skipping, "migrations (don't forget to run rake db:migrate)"
      end
    end

    def populate_seed_data
      if @load_seed_data
        say_status :loading, "seed data"
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

    def complete
      say_status :complete, "Solidus has been installed successfully. Enjoy!"
    end

    private

    def generate(what, *args)
      args << '--auto-accept' if options[:auto_accept]
      args << '--auto-run-migrations' if options[:migrate]
      super(what, *args)
    end

    def bundle_command(command, env = {})
      # Make `bundle install` less verbose by skipping the "Using ..." messages
      super(command, env.reverse_merge('BUNDLE_SUPPRESS_INSTALL_USING_MESSAGES' => 'true'))
    end

    def detect_frontend_to_install
      ENV['FRONTEND'] ||
        options[:frontend] ||
        (Bundler.locked_gems.dependencies[LEGACY_FRONTEND] && LEGACY_FRONTEND) ||
        (options[:auto_accept] && DEFAULT_FRONTEND) ||
        ask(<<~MSG.indent(8), default: DEFAULT_FRONTEND, limited_to: FRONTENDS.keys)

          Which frontend would you like to use?
          Selecting #{DEFAULT_FRONTEND} is recommended.
          However, some extensions are still only compatible with the now deprecated #{LEGACY_FRONTEND}.

        MSG
    end

    def detect_authentication_to_install
      ENV['AUTHENTICATION'] ||
        options[:authentication] ||
        (Bundler.locked_gems.dependencies['solidus_auth_devise'] && 'devise') ||
        (options[:auto_accept] && DEFAULT_AUTHENTICATION) ||
        ask(<<~MSG.indent(8), default: DEFAULT_AUTHENTICATION, limited_to: AUTHENTICATIONS.keys)

          Which authentication method would you like to use?
          Selecting "#{DEFAULT_AUTHENTICATION}" is recommended.

        MSG
    end
  end
end
