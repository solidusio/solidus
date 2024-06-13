# frozen_string_literal: true

# Replace solidus core's order contents and promotion adjuster classes with ours.
Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
Spree::Config.promotion_adjuster_class = "SolidusFriendlyPromotions::FriendlyPromotionAdjuster"

Rails.application.config.to_prepare do |config|
  Spree::Order.line_item_comparison_hooks << :free_from_order_benefit?
end

# Replace the promotions menu from core with ours
Spree::Backend::Config.configure do |config|
  config.menu_items = config.menu_items.map do |item|
    next item unless item.label.to_sym == :promotions

    # The API of the MenuItem class changes in Solidus 4.2.0
    if item.respond_to?(:children)
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
    else
      Spree::BackendConfiguration::MenuItem.new(
        [:promotions, :promotion_categories],
        "bullhorn",
        partial: "solidus_friendly_promotions/admin/shared/promotion_sub_menu",
        condition: -> { can?(:admin, SolidusFriendlyPromotions::Promotion) },
        url: -> { SolidusFriendlyPromotions::Engine.routes.url_helpers.admin_promotions_path },
        position: 2
      )
    end
  end
end

SolidusFriendlyPromotions.configure do |config|
  # This class chooses which promotion should apply to a line item in case
  # that more than one promotion is eligible.
  config.discount_chooser_class = "SolidusFriendlyPromotions::FriendlyPromotionAdjuster::ChooseDiscounts"

  # How many promotions should be displayed on the index page in the admin.
  config.promotions_per_page = 25

  config.promotion_calculators = SolidusFriendlyPromotions::NestedClassSet.new(
    "SolidusFriendlyPromotions::Benefits::AdjustShipment" => [
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::FlexiRate",
      "SolidusFriendlyPromotions::Calculators::Percent",
      "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
      "SolidusFriendlyPromotions::Calculators::TieredPercent",
      "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
    ],
    "SolidusFriendlyPromotions::Benefits::AdjustLineItem" => [
      "SolidusFriendlyPromotions::Calculators::DistributedAmount",
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::FlexiRate",
      "SolidusFriendlyPromotions::Calculators::Percent",
      "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
      "SolidusFriendlyPromotions::Calculators::TieredPercent",
      "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
    ],
    "SolidusFriendlyPromotions::Benefits::AdjustLineItemQuantityGroups" => [
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::Percent",
      "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
    ],
    "SolidusFriendlyPromotions::Benefits::CreateDiscountedItem" => [
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::Percent",
      "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
    ]
  )

  config.order_conditions = [
    "SolidusFriendlyPromotions::Conditions::FirstOrder",
    "SolidusFriendlyPromotions::Conditions::FirstRepeatPurchaseSince",
    "SolidusFriendlyPromotions::Conditions::ItemTotal",
    "SolidusFriendlyPromotions::Conditions::DiscountedItemTotal",
    "SolidusFriendlyPromotions::Conditions::MinimumQuantity",
    "SolidusFriendlyPromotions::Conditions::NthOrder",
    "SolidusFriendlyPromotions::Conditions::OneUsePerUser",
    "SolidusFriendlyPromotions::Conditions::OptionValue",
    "SolidusFriendlyPromotions::Conditions::Product",
    "SolidusFriendlyPromotions::Conditions::Store",
    "SolidusFriendlyPromotions::Conditions::Taxon",
    "SolidusFriendlyPromotions::Conditions::UserLoggedIn",
    "SolidusFriendlyPromotions::Conditions::UserRole",
    "SolidusFriendlyPromotions::Conditions::User"
  ]
  config.line_item_conditions = [
    "SolidusFriendlyPromotions::Conditions::LineItemOptionValue",
    "SolidusFriendlyPromotions::Conditions::LineItemProduct",
    "SolidusFriendlyPromotions::Conditions::LineItemTaxon"
  ]
  config.shipment_conditions = [
    "SolidusFriendlyPromotions::Conditions::ShippingMethod"
  ]

  config.actions = [
    "SolidusFriendlyPromotions::Benefits::AdjustLineItem",
    "SolidusFriendlyPromotions::Benefits::AdjustLineItemQuantityGroups",
    "SolidusFriendlyPromotions::Benefits::AdjustShipment",
    "SolidusFriendlyPromotions::Benefits::CreateDiscountedItem"
  ]
end
