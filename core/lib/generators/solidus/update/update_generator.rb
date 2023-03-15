# frozen_string_literal: true

require 'spree/preferences/preference_differentiator'
require 'rails/generators'

module Solidus
  # @private
  class UpdateGenerator < ::Rails::Generators::Base
    FROM = Spree.previous_solidus_minor_version

    desc 'Generates a new initializer to preview the new defaults for current Solidus version and copy new migrations'

    source_root File.expand_path('templates', __dir__)

    class_option :initializer_basename,
                 type: :string,
                 default: 'new_solidus_defaults',
                 banner: 'The name for the new initializer'

    class_option :previous_version_prompt,
                 type: :boolean,
                 default: true,
                 banner: 'Prompt to warn about only previous version support'

    class_option :from,
                 type: :string,
                 default: FROM,
                 banner: 'Solidus version from which you are upgrading'

    class_option :to,
                 type: :string,
                 default: Spree.solidus_version,
                 hide: true

    class_option :initializer_directory,
                 type: :string,
                 default: 'config/initializers/',
                 hide: true

    class_option :install_migrations,
                 type: :boolean,
                 default: true,
                 hide: true

    def create_new_defaults_initializer
      previous_version_prompt = options[:previous_version_prompt]
      return if previous_version_prompt && !yes?(<<~MSG, :red)
        The default preferences update process is only supported if you are coming from version #{FROM}. If this is not the case, please, skip it and update your application to use Solidus #{FROM} before retrying.
        If you are confident you want to upgrade from a previous version, you must rerun the generator with the "--from={OLD_VERSION}" argument.
        Are you sure you want to continue? (y/N)
      MSG

      from = options[:from]
      to = options[:to]
      @from = from
      @core_changes = core_changes_template(from, to)
      @frontend_changes = frontend_changes_template(from, to)
      @backend_changes = backend_changes_template(from, to)
      @api_changes = api_changes_template(from, to)

      template 'config/initializers/new_solidus_defaults.rb.tt',
               File.join(options[:initializer_directory], "#{options[:initializer_basename]}.rb")
    end

    def install_migrations
      return unless options[:install_migrations]

      say_status :copying, "migrations"
      rake 'spree:install:migrations'
    end

    def print_message
      say <<~MSG

        ***********************************************************************

        Other tasks may be needed to update to the new Solidus version. Please,
        check https://github.com/solidusio/solidus/blob/v#{options[:to]}/CHANGELOG.md
        for details.

        Thanks for using Solidus!

        ***********************************************************************

      MSG
    end

    private

    def core_changes_template(from, to)
      changes_template_for(Spree::AppConfiguration, from, to)
    end

    def frontend_changes_template(from, to)
      return '' unless defined?(Spree::Frontend::Engine)

      changes_template_for(Spree::FrontendConfiguration, from, to)
    end

    def backend_changes_template(from, to)
      return '' unless defined?(Spree::Backend::Engine)

      changes_template_for(Spree::BackendConfiguration, from, to)
    end

    def api_changes_template(from, to)
      return '' unless defined?(Spree::Api::Engine)

      changes_template_for(Spree::ApiConfiguration, from, to)
    end

    def changes_template_for(klass, from, to)
      changes = Spree::Preferences::PreferenceDifferentiator.new(klass).call(from: from, to: to)
      return '# No changes' if changes.empty?

      [
        ["config.load_defaults('#{from}')"] +
          changes.map do |pref_key, change|
            "  # config.#{pref_key} = #{change[:to]}"
          end.flatten
      ].join("\n")
    end
  end
end
