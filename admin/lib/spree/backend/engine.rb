# frozen_string_literal: true

module Spree
  module Backend
    class Engine < ::Rails::Engine
      config.middleware.use "Spree::Backend::Middleware::SeoAssist"

      initializer "spree.backend.environment", before: :load_config_initializers do |_app|
        Spree::Backend::Config = Spree::BackendConfiguration.new
      end
    end
  end
end
