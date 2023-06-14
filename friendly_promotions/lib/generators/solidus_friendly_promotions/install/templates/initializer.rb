# frozen_string_literal: true

SolidusFriendlyPromotions.configure do |config|
  # TODO: Remember to change this with the actual preferences you have implemented!
  # config.sample_preference = 'sample_value'
end

Rails.application.config.to_prepare do
  SolidusFriendlyPromotions::Actions::AdjustShipment.available_calculators += [
    SolidusFriendlyPromotions::Calculators::FlatRate,
    SolidusFriendlyPromotions::Calculators::FlexiRate,
    SolidusFriendlyPromotions::Calculators::Percent,
    SolidusFriendlyPromotions::Calculators::TieredFlatRate,
    SolidusFriendlyPromotions::Calculators::TieredPercent,
  ]
end
