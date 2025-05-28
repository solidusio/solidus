# frozen_string_literal: true

require "solidus_legacy_promotions"
require "flickwerk"
module SolidusLegacyPromotions
  class Engine < ::Rails::Engine
    include SolidusSupport::EngineExtensions

    include Flickwerk

    initializer "solidus_legacy_promotions.add_backend_menu_item" do
      if SolidusSupport.backend_available?
        promotions_menu_item = Spree::BackendConfiguration::MenuItem.new(
          label: :legacy_promotions,
          icon: Spree::Backend::Config.admin_updated_navbar ? "ri-megaphone-line" : "bullhorn",
          partial: "spree/admin/shared/promotion_sub_menu",
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path,
          data_hook: :admin_promotion_sub_tabs,
          children: [
            Spree::BackendConfiguration::MenuItem.new(
              label: :legacy_promotions,
              condition: -> { can?(:admin, Spree::Promotion) },
              url: :admin_promotions_path
            ),
            Spree::BackendConfiguration::MenuItem.new(
              label: :legacy_promotion_categories,
              condition: -> { can?(:admin, Spree::PromotionCategory) },
              url: -> { Spree::Core::Engine.routes.url_helpers.admin_promotion_categories_path }
            )
          ]
        )
        product_menu_item_index = Spree::Backend::Config.menu_items.find_index { |item| item.label == :products }
        Spree::Backend::Config.menu_items.insert(product_menu_item_index + 1, promotions_menu_item)
      end
    end

    initializer "solidus_legacy_promotions.add_admin_order_index_component" do
      if SolidusSupport.admin_available?
        SolidusAdmin::Config.components["orders/index"] = "SolidusLegacyPromotions::Orders::Index::Component"
      end
    end

    initializer "solidus_legacy_promotions.add_solidus_admin_menu_items" do
      if SolidusSupport.admin_available?
        SolidusAdmin::Config.configure do |config|
          config.menu_items << {
            key: "legacy_promotions",
            route: -> { spree.admin_promotions_path },
            icon: "megaphone-line",
            position: 1.5,
            children: [
              {
                key: "legacy_promotions",
                route: -> { spree.admin_promotions_path },
                position: 1
              },
              {
                key: "legacy_promotion_categories",
                route: -> { spree.admin_promotion_categories_path },
                position: 2
              }
            ]
          }
        end
      end
    end

    initializer "solidus_legacy_promotions.add_order_search_field" do
      if SolidusSupport.backend_available?
        email_field_index = Spree::Backend::Config.search_fields["spree/admin/orders"].find_index do |field|
          field.dig(:locals, :ransack) == :email_start
        end
        Spree::Backend::Config.search_fields["spree/admin/orders"].insert(email_field_index + 1, {
          partial: "spree/admin/shared/search_fields/text_field",
          locals: {
            ransack: :order_promotions_promotion_code_value_start,
            label: -> { I18n.t(:promotion, scope: :spree) }
          }
        })
      end
    end

    initializer "solidus_legacy_promotions.core.pub_sub", after: "spree.core.pub_sub" do |app|
      app.reloader.to_prepare do
        Spree::OrderPromotionSubscriber.new.subscribe_to(Spree::Bus)
      end
    end

    initializer "solidus_legacy_promotions.assets" do |app|
      app.config.assets.precompile << "solidus_legacy_promotions/manifest.js"
    end

    initializer "solidus_legacy_promotions.add_factories_to_core" do
      if Rails.env.test?
        require "spree/testing_support/factory_bot"
        require "solidus_legacy_promotions/testing_support/factory_bot"
        Spree::TestingSupport::FactoryBot.definition_file_paths.concat(SolidusLegacyPromotions::TestingSupport::FactoryBot.definition_file_paths)
      end
    rescue LoadError
      # FactoryBot is not available, we don't need factories
    end

    initializer "solidus_legacy_promotions", after: "spree.load_config_initializers" do
      # Only set these if there is no promotion configuration set. In this case,
      # we're running on a store without the new `solidus_promotions` gem and we
      # need to set the configuration to the legacy one.
      if Spree::Config.promotions.is_a?(Spree::Core::NullPromotionConfiguration)
        Spree::Config.order_contents_class = "Spree::OrderContents"
        Spree::Config.promotions = SolidusLegacyPromotions::Configuration.new
      end

      Spree::Api::Config.adjustment_attributes << :promotion_code_id
      Spree::Api::Config.adjustment_attributes << :eligible
      Spree::Config.adjustment_promotion_source_types << "Spree::PromotionAction"
    end
  end
end
