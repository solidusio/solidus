# frozen_string_literal: true

# Replace solidus core's order contents and promotion adjuster classes with ours.
Spree::Config.order_contents_class = "SolidusFriendlyPromotions::SimpleOrderContents"
Spree::Config.promotion_adjuster_class = "SolidusFriendlyPromotions::OrderDiscounter"

# Replace the promotions menu from core with ours
Spree::Backend::Config.configure do |config|
  config.menu_items = config.menu_items.map do |item|
    next item unless item.label.to_sym == :promotions

    # The API of the MenuItem class changes in Solidus 4.2.0
    if item.respond_to?(:children)
      Spree::BackendConfiguration::MenuItem.new(
        label: :promotions,
        icon: "bullhorn",
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
  config.discount_chooser_class = "SolidusFriendlyPromotions::DiscountChooser"

  # How many promotions should be displayed on the index page in the admin.
  config.promotions_per_page = 25

  config.promotion_calculators = SolidusFriendlyPromotions::NestedClassSet.new(
    "SolidusFriendlyPromotions::Actions::AdjustShipment" => [
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::FlexiRate",
      "SolidusFriendlyPromotions::Calculators::Percent",
      "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
      "SolidusFriendlyPromotions::Calculators::TieredPercent"
    ],
    "SolidusFriendlyPromotions::Actions::AdjustLineItem" => [
      "SolidusFriendlyPromotions::Calculators::DistributedAmount",
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::FlexiRate",
      "SolidusFriendlyPromotions::Calculators::Percent",
      "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
      "SolidusFriendlyPromotions::Calculators::TieredPercent"
    ],
    "SolidusFriendlyPromotions::Actions::AdjustLineItemQuantityGroups" => [
      "SolidusFriendlyPromotions::Calculators::FlatRate",
      "SolidusFriendlyPromotions::Calculators::Percent"
    ]
  )

  config.order_rules = [
    "SolidusFriendlyPromotions::Rules::FirstOrder",
    "SolidusFriendlyPromotions::Rules::FirstRepeatPurchaseSince",
    "SolidusFriendlyPromotions::Rules::ItemTotal",
    "SolidusFriendlyPromotions::Rules::DiscountedItemTotal",
    "SolidusFriendlyPromotions::Rules::MinimumQuantity",
    "SolidusFriendlyPromotions::Rules::NthOrder",
    "SolidusFriendlyPromotions::Rules::OneUsePerUser",
    "SolidusFriendlyPromotions::Rules::OptionValue",
    "SolidusFriendlyPromotions::Rules::Product",
    "SolidusFriendlyPromotions::Rules::Store",
    "SolidusFriendlyPromotions::Rules::Taxon",
    "SolidusFriendlyPromotions::Rules::UserLoggedIn",
    "SolidusFriendlyPromotions::Rules::UserRole",
    "SolidusFriendlyPromotions::Rules::User"
  ]
  config.line_item_rules = [
    "SolidusFriendlyPromotions::Rules::LineItemOptionValue",
    "SolidusFriendlyPromotions::Rules::LineItemProduct",
    "SolidusFriendlyPromotions::Rules::LineItemTaxon"
  ]
  config.shipment_rules = [
    "SolidusFriendlyPromotions::Rules::ShippingMethod"
  ]

  config.actions = [
    "SolidusFriendlyPromotions::Actions::AdjustLineItem",
    "SolidusFriendlyPromotions::Actions::AdjustLineItemQuantityGroups",
    "SolidusFriendlyPromotions::Actions::AdjustShipment"
  ]
end
