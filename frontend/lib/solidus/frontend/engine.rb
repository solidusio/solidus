module Spree
  module Frontend
    class Engine < ::Rails::Engine
      config.middleware.use "Solidus::Frontend::Middleware::SeoAssist"

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "spree.assets.precompile", :group => :all do |app|
        app.config.assets.precompile += %w[
          spree/frontend/all*
          jquery.validate/localization/messages_*
        ]
      end

      initializer "spree.frontend.environment", :before => :load_config_initializers do |app|
        Solidus::Frontend::Config = Solidus::FrontendConfiguration.new
      end
    end
  end
end
