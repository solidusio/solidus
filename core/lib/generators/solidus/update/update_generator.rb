# frozen_string_literal: true

require 'spree/core/preference_changes_between_solidus_versions'
require 'rails/generators'

module Solidus
  class UpdateGenerator < ::Rails::Generators::Base
    desc 'Generates a new initializer to preview the new defaults for current Solidus version'

    source_root File.expand_path('templates', __dir__)

    class_option :from,
                 type: :string,
                 banner: 'The version your are updating from. E.g. 2.11.10'

    class_option :initializer_basename,
                 type: :string,
                 default: 'new_solidus_defaults',
                 banner: 'The name for the new initializer'

    class_option :to,
                 type: :string,
                 default: Spree.solidus_version,
                 hide: true

    class_option :initializer_directory,
                 type: :string,
                 default: 'config/initializers/',
                 hide: true

    def create_new_defaults_initializer
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
      changes = Spree::Core::PreferenceChangesBetweenSolidusVersions.new(klass).call(from: from, to: to)
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
