# frozen_string_literal: true

require 'rails/version'
require 'rails/generators'
require 'rails/generators/app_base'

module Solidus
  # @private
  class InstallGenerator < Rails::Generators::AppBase
    argument :app_path, type: :string, default: Rails.root

    CORE_MOUNT_ROUTE = "mount Spree::Core::Engine"

    FRONTENDS = %w[
      none
      classic
      starter
    ]

    LEGACY_FRONTENDS = %w[
      solidus_starter_frontend
      solidus_frontend
    ]

    AUTHENTICATIONS = %w[
      devise
      existing
      custom
      none
    ]

    PAYMENT_METHODS = [
      {
        name: 'paypal',
        frontends: %w[none classic starter],
        description: 'Install `solidus_paypal_commerce_platform`',
        default: true,
      },
      {
        name: 'bolt',
        frontends: %w[classic],
        description: 'Install `solidus_bolt`',
        default: false,
      },
      {
        name: 'none',
        frontends: %w[none classic starter],
        description: 'Skip installing a payment method',
        default: false,
      },
    ]

    class_option :migrate, type: :boolean, default: true, banner: 'Run Solidus migrations'
    class_option :seed, type: :boolean, default: true, banner: 'Load seed data (migrations must be run)'
    class_option :sample, type: :boolean, default: true, banner: 'Load sample data (migrations and seeds must be run)'
    class_option :active_storage, type: :boolean, default: (
      Rails.gem_version >= Gem::Version.new("6.1.0")
    ), banner: 'Install ActiveStorage as image attachments handler for products and taxons'
    class_option :auto_accept, type: :boolean
    class_option :user_class, type: :string
    class_option :admin_email, type: :string
    class_option :admin_password, type: :string

    class_option :frontend, type: :string, enum: FRONTENDS + LEGACY_FRONTENDS, default: nil, desc: "Indicates which frontend to install."
    class_option :authentication, type: :string, enum: AUTHENTICATIONS, default: nil, desc: "Indicates which authentication system to install."
    class_option :payment_method, type: :string, enum: PAYMENT_METHODS.map { |payment_method| payment_method[:name] }, default: nil, desc: "Indicates which payment method to install."

    # DEPRECATED
    class_option :with_authentication, type: :boolean, hide: true, default: nil
    class_option :enforce_available_locales, type: :boolean, hide: true, default: nil
    class_option :lib_name, type: :string, hide: true, default: nil

    source_root "#{__dir__}/templates"

    def self.exit_on_failure?
      true
    end

    def prepare_options
      @run_migrations = options[:migrate]
      @load_seed_data = options[:seed] && @run_migrations
      @load_sample_data = options[:sample] && @run_migrations && @load_seed_data
      @selected_frontend = detect_frontend_to_install
      @selected_authentication = detect_authentication_to_install
      @selected_payment_method = detect_payment_method_to_install

      # Silence verbose output (e.g. Rails migrations will rely on this environment variable)
      ENV['VERBOSE'] = 'false'

      # No reason to check for their presence if we're about to install them
      ENV['SOLIDUS_SKIP_MIGRATIONS_CHECK'] = 'true'

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
        Spree::Core::Engine.load_seed
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

    def run_migrations
      if @run_migrations
        say_status :running, "migrations"

        rake 'db:migrate'
      else
        say_status :skipping, "migrations (don't forget to run rake db:migrate)"
      end
    end

    def install_authentication
      apply_template_for :authentication, @selected_authentication
    end

    def install_frontend
      apply_template_for :frontend, @selected_frontend
    end

    def install_payment_method
      apply_template_for :payment_method, @selected_payment_method
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

    def generate(what, *args, abort_on_failure: true)
      args << '--auto-accept' if options[:auto_accept]
      args << '--auto-run-migrations' if options[:migrate]
      super(what, *args, abort_on_failure: abort_on_failure)
    end

    def bundle_command(command, env = {})
      # Make `bundle install` less verbose by skipping the "Using ..." messages
      super(command, env.reverse_merge('BUNDLE_SUPPRESS_INSTALL_USING_MESSAGES' => 'true'))
    ensure
      Bundler.reset_paths!
    end

    def ask_with_description(desc:, limited_to:, default:)
      loop do
        say_status :question, desc, :yellow
        answer = ask(set_color("answer:".rjust(13), :blue, :bold)).to_s.downcase.presence

        case answer
        when nil
          say_status :using, "#{default} (default)"
          break default
        when *limited_to.map(&:to_s)
          say_status :using, answer
          break answer
        else say_status :error, "Please select a valid answer:", :red
        end
      end
    end

    def apply_template_for(topic, selected)
      template_path = Dir["#{__dir__}/app_templates/#{topic}/*.rb"].find do |path|
        File.basename(path, '.rb') == selected
      end

      unless template_path
        say_status :warning, "Unknown #{topic}: #{selected.inspect}, attempting to run it with `rails app:template`"
        template_path = selected
      end

      say_status :installing, "[#{topic}] #{selected}", :blue
      apply template_path
    end

    def with_env(vars)
      original = ENV.to_hash
      vars.each { |k, v| ENV[k] = v }

      begin
        yield
      ensure
        ENV.replace(original)
      end
    end

    def detect_frontend_to_install
      # We need to support names that were available in v3.2
      selected_frontend = 'starter' if options[:frontend] == 'solidus_starter_frontend'
      selected_frontend = 'classic' if options[:frontend] == 'solidus_frontend'
      selected_frontend ||= options[:frontend]

      ENV['FRONTEND'] ||
        selected_frontend ||
        (Bundler.locked_gems.dependencies['solidus_frontend'] && 'classic') ||
        (options[:auto_accept] && 'starter') ||
        ask_with_description(
          default: 'starter',
          limited_to: FRONTENDS,
          desc: <<~TEXT
            Which frontend would you like to use?

            - [#{set_color 'starter', :bold}] Generate all necessary controllers and views directly in your Rails app (#{set_color :default, :bold}).
            - [#{set_color 'classic', :bold}] Install `solidus_frontend`, was the default in previous solidus versions (#{set_color :deprecated, :bold}).
            - [#{set_color 'none', :bold}] Skip installing a frontend.

            Selecting `starter` is recommended, however, some extensions are still only compatible with `classic`.
          TEXT
        )
    end

    def detect_authentication_to_install
      return 'devise' if @selected_frontend == 'starter'

      if options[:with_authentication] != nil
        say_status :warning, \
          "Using `solidus:install --with-authentication` is now deprecated. " \
          "Please use `--authentication` instead (see --help for the full list of options).",
          :red

        if options[:with_authentication] == 'false'
          # Don't use the default authentication if the user explicitly
          # requested no authentication system.
          return 'none'
        else
          return 'devise'
        end
      end

      ENV['AUTHENTICATION'] ||
        options[:authentication] ||
        (Bundler.locked_gems.dependencies['solidus_auth_devise'] && 'devise') ||
        (options[:auto_accept] && 'devise') ||
        ask_with_description(
          default: 'devise',
          limited_to: AUTHENTICATIONS,
          desc: <<~TEXT
            Which authentication would you like to use?

            - [#{set_color 'devise', :bold}] Install and configure the standard `devise` integration. (#{set_color :default, :bold}).
            - [#{set_color 'existing', :bold}] Integrate and configure an existing `devise` setup.
            - [#{set_color 'custom', :bold}] A starter configuration for rolling your own authentication system.
            - [#{set_color 'none', :bold}] Don't add any configuration for authentication.

            Selecting `devise` is recommended.
          TEXT
        )
    end

    def detect_payment_method_to_install
      return 'paypal' if Bundler.locked_gems.dependencies['solidus_paypal_commerce_platform']
      return 'bolt' if Bundler.locked_gems.dependencies['solidus_bolt']

      selected_frontend_payment_methods = PAYMENT_METHODS.select do |payment_method|
        payment_method[:frontends].include?(@selected_frontend)
      end

      selected = options[:payment_method] || (options[:auto_accept] && 'paypal') ||
        ask_with_description(
          default: 'paypal',
          limited_to: selected_frontend_payment_methods.map { |payment_method| payment_method[:name] },
          desc: <<~TEXT
            Which payment method would you like to use?

            #{selected_frontend_payment_methods.map { |payment_method| formatted_payment_method_description(payment_method) }.join("\n")}
          TEXT
        )
    end

    def formatted_payment_method_description(payment_method)
      default_label = " (#{set_color :default, :bold})" if payment_method[:default]

      "- [#{set_color payment_method[:name], :bold}] #{payment_method[:description]}#{default_label}."
    end
  end
end
