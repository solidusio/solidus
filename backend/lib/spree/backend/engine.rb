# frozen_string_literal: true

require 'spree/backend/config'

module Spree
  module Backend
    class Engine < ::Rails::Engine
      # Leave initializer empty for backwards-compatability. Other apps
      # might still rely on this event.
      initializer "spree.backend.environment", before: :load_config_initializers do; end
    end
  end
end
