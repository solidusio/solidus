module Spree
  module Frontend
    class Engine < ::Rails::Engine
      config.middleware.use "Spree::Frontend::Middleware::SeoAssist"

      initializer "spree.frontend.environment", before: :load_config_initializers do |_app|
        Spree::Frontend::Config = Spree::FrontendConfiguration.new
      end
    end
  end
end
