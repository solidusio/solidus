require 'globalize'
require 'friendly_id/globalize'

module SpreeI18n
  class Engine < Rails::Engine
    engine_name 'spree_i18n'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'spree-i18n' do |app|
      SpreeI18n::Engine.instance_eval do
        pattern = pattern_from app.config.i18n.available_locales

        add("config/locales/#{pattern}/*.{rb,yml}")
        add("config/locales/#{pattern}.{rb,yml}")
      end
    end

    initializer "spree_i18n.environment", before: :load_config_initializers do |app|
      app.config.i18n.fallbacks = true
      I18n.locale = app.config.i18n.default_locale if app.config.i18n.default_locale
      SpreeI18n::Config = SpreeI18n::Configuration.new
    end

    initializer "spree_i18n.permitted_attributes", before: :load_config_initializers do |app|
      taxon_attributes = { translations_attributes: [:id, :locale, :name, :description, :permalink, :meta_description, :meta_keywords, :meta_title] }
      Spree::PermittedAttributes.taxon_attributes << taxon_attributes

      option_value_attributes = { translations_attributes: [:id, :locale, :name, :presentation] }
      Spree::PermittedAttributes.option_value_attributes << option_value_attributes
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    protected
    def self.add(pattern)
      files = Dir[File.join(File.dirname(__FILE__), '../..', pattern)]
      I18n.load_path.concat(files)
    end

    def self.pattern_from(args)
      array = Array(args || [])
      array.blank? ? '*' : "{#{array.join ','}}"
    end
  end
end
