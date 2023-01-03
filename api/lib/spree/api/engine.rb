# frozen_string_literal: true

require 'spree/api/config'

module Spree
  module Api
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_api'

      # Leave initializer empty for backwards-compatibility. Other apps
      # might still rely on this event.
      initializer "spree.api.environment", before: :load_config_initializers do; end

      config.after_initialize do
        Spree::Api::Config.check_load_defaults_called('Spree::Api::Config')
      end
    end
  end
end

