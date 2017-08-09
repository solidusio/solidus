require 'rails/engine'

module Spree
  module Api
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_api'

      initializer "spree.api.environment", before: :load_config_initializers do |_app|
        Spree::Api::Config = Spree::ApiConfiguration.new
      end

      initializer "spree.api.versioncake" do |_app|
        VersionCake.setup do |config|
          config.resources do |r|
            r.resource %r{.*}, [], [], [1]
          end
          config.missing_version = 1
          config.extraction_strategy = :http_header
        end
      end
    end
  end
end
