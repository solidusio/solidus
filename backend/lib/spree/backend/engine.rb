# frozen_string_literal: true

require "spree/backend/config"
require "spree/backend/remix_icons"

module Spree
  module Backend
    class Engine < ::Rails::Engine
      # Leave initializer empty for backwards-compatability. Other apps
      # might still rely on this event.
      initializer("spree.backend.environment", before: :load_config_initializers) {}

      config.after_initialize do
        Spree::Backend::Config.check_load_defaults_called("Spree::Backend::Config")
      end
    end
  end
end
