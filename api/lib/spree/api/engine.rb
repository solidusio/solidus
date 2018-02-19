# frozen_string_literal: true

require 'rails/engine'

module Spree
  module Api
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_api'

      initializer "spree.api.environment", before: :load_config_initializers do |_app|
        Spree::Api::Config = Spree::ApiConfiguration.new
      end
    end
  end
end
