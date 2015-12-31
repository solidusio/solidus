module Spree
  module Backend
    class Engine < ::Rails::Engine
      config.middleware.use "Solidus::Backend::Middleware::SeoAssist"

      initializer "solidus.backend.environment", :before => :load_config_initializers do |app|
        Solidus::Backend::Config = Solidus::BackendConfiguration.new
      end

      # filter sensitive information during logging
      initializer "solidus.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :number]
      end

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "solidus.assets.precompile", :group => :all do |app|
        app.config.assets.precompile += %w[
          solidus/backend/all*
          solidus/backend/orders/edit_form.js
          solidus/backend/address_states.js
          jqPlot/excanvas.min.js
          solidus/backend/images/new.js
          jquery.jstree/themes/apple/*
          fontawesome-webfont*
          select2_locale*
        ]
      end
    end
  end
end
