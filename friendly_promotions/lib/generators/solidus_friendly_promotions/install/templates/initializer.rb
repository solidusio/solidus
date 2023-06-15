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
end
