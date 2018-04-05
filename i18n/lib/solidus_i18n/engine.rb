require 'kaminari-i18n/engine'

module SolidusI18n
  class Engine < Rails::Engine
    engine_name 'solidus_i18n'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'solidus.i18n.environment', before: :load_config_initializers do |app|
      I18n.locale = app.config.i18n.default_locale if app.config.i18n.default_locale
      SolidusI18n::Config = SolidusI18n::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
