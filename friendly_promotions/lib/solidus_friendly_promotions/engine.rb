# frozen_string_literal: true

require "solidus_core"
require "solidus_support"

module SolidusFriendlyPromotions
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::SolidusFriendlyPromotions

    engine_name "solidus_friendly_promotions"

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "solidus_friendly_promotions.assets" do |app|
      if SolidusSupport.backend_available?
        app.config.assets.precompile << "solidus_friendly_promotions/manifest.js"
      end
    end

    initializer "solidus_friendly_promotions.importmap" do |app|
      if SolidusSupport.backend_available?
        SolidusFriendlyPromotions.importmap.draw(Engine.root.join("config", "importmap.rb"))

        package_path = Engine.root.join("app/javascript")
        app.config.assets.paths << package_path

        if app.config.importmap.sweep_cache
          SolidusFriendlyPromotions.importmap.cache_sweeper(watches: package_path)
          ActiveSupport.on_load(:action_controller_base) do
            before_action { SolidusFriendlyPromotions.importmap.cache_sweeper.execute_if_updated }
          end
        end
      end
    end

    initializer "solidus_friendly_promotions.spree_config", after: "spree.load_config_initializers" do
      Spree::Config.adjustment_promotion_source_types << "SolidusFriendlyPromotions::Benefit"
    end

    initializer "solidus_friendly_promotions.core.pub_sub", after: "spree.core.pub_sub" do |app|
      app.reloader.to_prepare do
        SolidusFriendlyPromotions::OrderPromotionSubscriber.new.subscribe_to(Spree::Bus)
      end
    end
  end
end
