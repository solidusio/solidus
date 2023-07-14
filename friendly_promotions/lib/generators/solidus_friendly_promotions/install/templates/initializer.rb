# frozen_string_literal: true

# Replace solidus core's order contents and promotion adjuster classes with ours.
Spree::Config.order_contents_class = "SolidusFriendlyPromotions::SimpleOrderContents"
Spree::Config.promotion_adjuster_class = "SolidusFriendlyPromotions::OrderPromotionAdjuster"

# Replace the promotions menu from core with ours
Spree::Backend::Config.configure do |config|
  config.menu_items = Spree::Backend::Config.menu_items.map do |item|
    next item unless item.url == :admin_promotions_path
    Spree::BackendConfiguration::MenuItem.new(
      [:promotions, :promotion_categories],
      'bullhorn',
      partial: 'spree/admin/shared/promotion_sub_menu',
      condition: -> { can?(:admin, Spree::Promotion) },
      url: -> { SolidusFriendlyPromotions::Engine.routes.url_helpers.admin_promotions_path },
      position: 2
    )
  end
end

SolidusFriendlyPromotions.configure do |config|
  # This class chooses which promotion should apply to a line item in case
  # that more than one promotion is eligible.
  config.promotion_chooser_class = "SolidusFriendlyPromotions::PromotionAdjustmentChooser"

  config.shipment_discount_calculators = [
    "SolidusFriendlyPromotions::Calculators::FlatRate",
    "SolidusFriendlyPromotions::Calculators::FlexiRate",
    "SolidusFriendlyPromotions::Calculators::Percent",
    "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
    "SolidusFriendlyPromotions::Calculators::TieredPercent",
  ]
  config.line_item_discount_calculators = [
    "SolidusFriendlyPromotions::Calculators::DistributedAmount",
    "SolidusFriendlyPromotions::Calculators::FlatRate",
    "SolidusFriendlyPromotions::Calculators::FlexiRate",
    "SolidusFriendlyPromotions::Calculators::Percent",
    "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
    "SolidusFriendlyPromotions::Calculators::TieredPercent",
  ]

  config.order_rules = [
    "SolidusFriendlyPromotions::Rules::FirstOrder",
    "SolidusFriendlyPromotions::Rules::FirstRepeatPurchaseSince",
    "SolidusFriendlyPromotions::Rules::ItemTotal",
    "SolidusFriendlyPromotions::Rules::NthOrder",
    "SolidusFriendlyPromotions::Rules::OneUsePerUser",
    "SolidusFriendlyPromotions::Rules::OptionValue",
    "SolidusFriendlyPromotions::Rules::Product",
    "SolidusFriendlyPromotions::Rules::Store",
    "SolidusFriendlyPromotions::Rules::Taxon",
    "SolidusFriendlyPromotions::Rules::UserLoggedIn",
    "SolidusFriendlyPromotions::Rules::UserRole",
    "SolidusFriendlyPromotions::Rules::User",
  ]
  config.line_item_rules = [
    "SolidusFriendlyPromotions::Rules::LineItemOptionValue",
    "SolidusFriendlyPromotions::Rules::LineItemProduct",
    "SolidusFriendlyPromotions::Rules::LineItemTaxon",
  ]
  config.shipment_rules = []

  config.actions = [
    "SolidusFriendlyPromotions::Actions::AdjustLineItem",
    "SolidusFriendlyPromotions::Actions::AdjustShipment",
  ]
end
