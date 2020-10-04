# frozen_string_literal: true

require 'spree/frontend/config'

module Spree
  module Frontend
    class Engine < ::Rails::Engine
      config.middleware.use "Spree::Frontend::Middleware::SeoAssist"

      # Leave initializer empty for backwards-compatability. Other apps
      # might still rely on this event.
      initializer "spree.frontend.environment", before: :load_config_initializers do; end
    end
  end
end
