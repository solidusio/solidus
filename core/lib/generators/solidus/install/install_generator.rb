# frozen_string_literal: true

require 'rails/version'
require 'rails/generators'
require 'rails/generators/app_base'

module Solidus
  # @private
  class InstallGenerator < Rails::Generators::AppBase
    argument :app_path, type: :string, default: Rails.root

    CORE_MOUNT_ROUTE = "mount Spree::Core::Engine"

    FRONTENDS = [
      { name: 'starter', description: 'Generate all necessary controllers and views directly in your Rails app', default: true },
      { name: 'none', description: 'Skip installing a frontend' }
    ]

    AUTHENTICATIONS = [
      { name: 'devise', description: 'Install and configure the standard `devise` integration', default: true },
      { name: 'existing', description: 'Integrate and configure an existing `devise` setup' },
      { name: 'custom', description: 'A starter configuration for rolling your own authentication system' },
      { name: 'none', description: 'Don\'t add any configuration for authentication' }
    ]

    PAYMENT_METHODS = [
      { name: 'paypal', description: 'Install `solidus_paypal_commerce_platform`', default: true },
      { name: 'stripe', description: 'Install `solidus_stripe`', default: false },
      { name: 'braintree', description: 'Install `solidus_braintree`', default: false },
      { name: 'none', description: 'Skip installing a payment method', default: false }
    ]

    class_option :migrate, type: :boolean, default: true, banner: 'Run Solidus migrations'
    class_option :seed, type: :boolean, default: true, banner: 'Load seed data (migrations must be run)'
    class_option :sample, type: :boolean, default: true, banner: 'Load sample data (migrations and seeds must be run)'
    class_option :active_storage, type: :boolean, default: true, banner: 'Install ActiveStorage as image attachments handler for products and taxons'
    class_option :auto_accept, type: :boolean
    class_option :user_class, type: :string
    class_option :admin_email, type: :string
    class_option :admin_password, type: :string

    class_option :frontend, type: :string, enum: FRONTENDS.map { _1[:name] }, default: nil, desc: "Indicates which frontend to install."
    class_option :authentication, type: :string, enum: AUTHENTICATIONS.map { _1[:name] }, default: nil, desc: "Indicates which authentication system to install."
    class_option :payment_method, type: :string, enum: PAYMENT_METHODS.map { _1[:name] }, default: nil, desc: "Indicates which payment method to install."

    source_root "#{__dir__}/templates"

    def self.exit_on_failure?
      true
    end

    def prepare_options
      @run_migrations = options[:migrate]
      @load_seed_data = options[:seed] && @run_migrations
      @load_sample_data = options[:sample] && @run_migrations && @load_seed_data

      @selected_frontend = selected_option_for(
        'frontend',
        selected: ENV['FRONTEND'] || options[:frontend],
        available_options: FRONTENDS,
      )

      @selected_authentication = selected_option_for(
        'authentication',
        selected:
          ('devise' if @selected_frontend == 'starter') ||
          ('devise' if has_gem?('solidus_auth_devise')) ||
          ENV['AUTHENTICATION'] || options[:authentication],
        available_options: AUTHENTICATIONS,
      )

      @selected_payment_method = selected_option_for(
        'payment method',
        selected:
          ('paypal' if has_gem?('solidus_paypal_commerce_platform')) ||
          ('stripe' if has_gem?('solidus_stripe')) ||
          ('bolt' if has_gem?('solidus_bolt')) ||
          ENV['PAYMENT_METHOD'] || options[:payment_method],
        available_options: PAYMENT_METHODS,
      )

      # Silence verbose output (e.g. Rails migrations will rely on this environment variable)
      ENV['VERBOSE'] = 'false'

      # No reason to check for their presence if we're about to install them
      ENV['SOLIDUS_SKIP_MIGRATIONS_CHECK'] = 'true'
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
        gsub_file 'config/initializers/spree.rb', "::ActiveStorageAttachment", "::PaperclipAttachment"
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

    def install_solidus_admin
      generate 'solidus_admin:install'
    end

    def install_subcomponents
      apply_template_for :authentication, @selected_authentication
      apply_template_for :frontend, @selected_frontend
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

    def has_gem?(name)
      Bundler.locked_gems.dependencies[name]
    end

    def selected_option_for(name, selected:, available_options:)
      return selected if selected

      option_description = ->(name:, description:, default: false, **) do
        default_label = " (#{set_color :default, :bold})" if default

        "- [#{set_color name, :bold}] #{description}#{default_label}."
      end

      default = available_options.find { _1[:default] }
      (options[:auto_accept] && default[:name]) || ask_with_description(
        default: default[:name],
        limited_to: available_options.map { _1[:name] },
        desc: <<~TEXT
          Which #{name} would you like to use?
          #{available_options.map { option_description[**_1] }.join("\n")}
        TEXT
      )
    end
  end
end
