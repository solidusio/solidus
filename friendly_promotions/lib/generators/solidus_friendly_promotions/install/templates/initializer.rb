# frozen_string_literal: true

# Make sure we use Spree::SimpleOrderContents
# Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
# Set the promotion configuration to ours
# Spree::Config.promotions = SolidusFriendlyPromotions.configuration

Rails.application.config.to_prepare do |config|
  Spree::Order.line_item_comparison_hooks << :free_from_order_benefit?
end

if SolidusSupport.backend_available?
  # Replace the promotions menu from core with ours
  Spree::Backend::Config.configure do |config|
    config.menu_items = config.menu_items.map do |item|
      next item unless item.label.to_sym == :promotions

      Spree::BackendConfiguration::MenuItem.new(
        label: :promotions,
        icon: config.admin_updated_navbar ? "ri-megaphone-line" : "bullhorn",
        condition: -> { can?(:admin, SolidusFriendlyPromotions::Promotion) },
        url: -> { SolidusFriendlyPromotions::Engine.routes.url_helpers.admin_promotions_path },
        data_hook: :admin_promotion_sub_tabs,
        children: [
          Spree::BackendConfiguration::MenuItem.new(
            label: :promotions,
            url: -> { SolidusFriendlyPromotions::Engine.routes.url_helpers.admin_promotions_path },
            condition: -> { can?(:admin, SolidusFriendlyPromotions::Promotion) }
          ),
          Spree::BackendConfiguration::MenuItem.new(
            label: :promotion_categories,
            url: -> { SolidusFriendlyPromotions::Engine.routes.url_helpers.admin_promotion_categories_path },
            condition: -> { can?(:admin, SolidusFriendlyPromotions::PromotionCategory) }
          ),
          Spree::BackendConfiguration::MenuItem.new(
            label: :legacy_promotions,
            condition: -> { can?(:admin, Spree::Promotion && Spree::Promotion.any?) },
            url: -> { Spree::Core::Engine.routes.url_helpers.admin_promotions_path },
            match_path: "/admin/promotions/"
          ),
          Spree::BackendConfiguration::MenuItem.new(
            label: :legacy_promotion_categories,
            condition: -> { can?(:admin, Spree::PromotionCategory && Spree::Promotion.any?) },
            url: -> { Spree::Core::Engine.routes.url_helpers.admin_promotion_categories_path },
            match_path: "/admin/promotion_categories/"
          )
        ]
      )
    end
  end
end

SolidusFriendlyPromotions.configure do |config|
  # Add your custom configuration here
end
