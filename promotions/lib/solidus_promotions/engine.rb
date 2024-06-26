# frozen_string_literal: true

require "solidus_core"
require "solidus_support"

module SolidusPromotions
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::SolidusPromotions

    engine_name "solidus_promotions"

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "solidus_promotions.assets" do |app|
      if SolidusSupport.backend_available?
        app.config.assets.precompile << "solidus_promotions/manifest.js"
      end
    end

    initializer "solidus_promotions.importmap" do |app|
      if SolidusSupport.backend_available?
        SolidusPromotions.importmap.draw(Engine.root.join("config", "importmap.rb"))

        package_path = Engine.root.join("app/javascript")
        app.config.assets.paths << package_path

        if app.config.importmap.sweep_cache
          SolidusPromotions.importmap.cache_sweeper(watches: package_path)
          ActiveSupport.on_load(:action_controller_base) do
            before_action { SolidusPromotions.importmap.cache_sweeper.execute_if_updated }
          end
        end
      end
    end

    initializer "solidus_promotions.spree_config", after: "spree.load_config_initializers" do
      Spree::Config.adjustment_promotion_source_types << "SolidusPromotions::Benefit"
    end

    initializer "solidus_promotions.core.pub_sub", after: "spree.core.pub_sub" do |app|
      app.reloader.to_prepare do
        SolidusPromotions::OrderPromotionSubscriber.new.subscribe_to(Spree::Bus)
      end
    end

    initializer "solidus_promotions.add_admin_order_index_component", after: "solidus_legacy_promotions.add_admin_order_index_component" do
      if SolidusSupport.admin_available?
        SolidusAdmin::Config.components["orders/index"] = "SolidusPromotions::Orders::Index::Component"
        SolidusAdmin::Config.components["promotions/index"] = "SolidusPromotions::Promotions::Index::Component"
        SolidusAdmin::Config.components["promotion_categories/index"] = "SolidusPromotions::PromotionCategories::Index::Component"
      end
    end
  end
end
