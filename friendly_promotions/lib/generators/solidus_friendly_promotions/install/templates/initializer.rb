# frozen_string_literal: true

SolidusFriendlyPromotions.configure do |config|
  # TODO: Remember to change this with the actual preferences you have implemented!
  # config.sample_preference = 'sample_value'
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
end
