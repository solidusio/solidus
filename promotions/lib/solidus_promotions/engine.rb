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

      Rails.application.config.to_prepare do
        Spree::Order.line_item_comparison_hooks << :free_from_order_benefit?
      end
    end

    initializer "solidus_promotions.core.pub_sub", after: "spree.core.pub_sub" do |app|
      app.reloader.to_prepare do
        SolidusPromotions::OrderPromotionSubscriber.new.subscribe_to(Spree::Bus)
      end
    end

    initializer "solidus_promotions.add_admin_order_index_component", after: "spree.load_config_initializers" do
      if SolidusSupport.admin_available?
        if Spree::Config.promotions.is_a?(SolidusPromotions::Configuration)
          SolidusAdmin::Config.components["orders/index"] = "SolidusPromotions::Orders::Index::Component"
        end

        SolidusAdmin::Config.components["solidus_promotions/promotions/index"] = "SolidusPromotions::Promotions::Index::Component"
        SolidusAdmin::Config.components["solidus_promotions/categories/index"] = "SolidusPromotions::PromotionCategories::Index::Component"
      end
    end

    initializer "solidus_promotions.add_solidus_admin_menu_items", after: "spree.load_config_initializers" do
      if SolidusSupport.admin_available?
        SolidusAdmin::Config.configure do |config|
          config.menu_items << {
            key: "promotions",
            route: -> { solidus_promotions.admin_promotions_path },
            icon: "megaphone-line",
            position: 1.6,
            children: [
              {
                key: "promotions",
                route: -> { solidus_promotions.admin_promotions_path },
                position: 1
              },
              {
                key: "promotion_categories",
                route: -> { solidus_promotions.admin_promotion_categories_path },
                position: 1
              }
            ]
          }
        end
      end
    end

    initializer "solidus_promotions.add_backend_menus", after: "spree.backend.environment" do
      if SolidusSupport.backend_available?
        promotions_menu_item = Spree::BackendConfiguration::MenuItem.new(
          label: :promotions,
          icon: Spree::Backend::Config.admin_updated_navbar ? "ri-megaphone-line" : "bullhorn",
          condition: -> { can?(:admin, SolidusPromotions::Promotion) },
          url: -> { SolidusPromotions::Engine.routes.url_helpers.admin_promotions_path },
          data_hook: :admin_solidus_promotion_sub_tabs,
          children: [
            Spree::BackendConfiguration::MenuItem.new(
              label: :promotions,
              url: -> { SolidusPromotions::Engine.routes.url_helpers.admin_promotions_path },
              condition: -> { can?(:admin, SolidusPromotions::Promotion) }
            ),
            Spree::BackendConfiguration::MenuItem.new(
              label: :promotion_categories,
              url: -> { SolidusPromotions::Engine.routes.url_helpers.admin_promotion_categories_path },
              condition: -> { can?(:admin, SolidusPromotions::PromotionCategory) }
            )
          ]
        )

        # We want to appear after the legacy promotions menu item if it exists, otherwise after the products menu item
        product_menu_item_index = Spree::Backend::Config.menu_items.find_index { |item| item.label == :products }
        legacy_promotions_menu_item = Spree::Backend::Config.menu_items.find_index { |item| item.label == :legacy_promotions }
        promotions_menu_index = [product_menu_item_index, legacy_promotions_menu_item].compact.max + 1

        Spree::Backend::Config.menu_items.insert(promotions_menu_index, promotions_menu_item)
      end
    end
  end
end
