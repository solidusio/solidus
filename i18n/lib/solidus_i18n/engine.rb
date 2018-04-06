require 'kaminari-i18n/engine'

module SolidusI18n
  class Engine < Rails::Engine
    engine_name 'solidus_i18n'

    config.autoload_paths += %W(#{config.root}/lib)
  end
end
