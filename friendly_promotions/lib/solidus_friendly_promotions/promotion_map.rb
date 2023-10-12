# frozen_string_literal: true

module SolidusFriendlyPromotions
  PROMOTION_MAP = {
    rules: {
      Spree::Promotion::Rules::ItemTotal =>
        SolidusFriendlyPromotions::Rules::ItemTotal,
      Spree::Promotion::Rules::Product =>
        SolidusFriendlyPromotions::Rules::Product,
      Spree::Promotion::Rules::User =>
        SolidusFriendlyPromotions::Rules::User,
      Spree::Promotion::Rules::FirstOrder =>
        SolidusFriendlyPromotions::Rules::FirstOrder,
      Spree::Promotion::Rules::UserLoggedIn =>
        SolidusFriendlyPromotions::Rules::UserLoggedIn,
      Spree::Promotion::Rules::OneUsePerUser =>
        SolidusFriendlyPromotions::Rules::OneUsePerUser,
      Spree::Promotion::Rules::Taxon =>
        SolidusFriendlyPromotions::Rules::LineItemTaxon,
      Spree::Promotion::Rules::NthOrder =>
        SolidusFriendlyPromotions::Rules::NthOrder,
      Spree::Promotion::Rules::OptionValue =>
        SolidusFriendlyPromotions::Rules::OptionValue,
      Spree::Promotion::Rules::FirstRepeatPurchaseSince =>
        SolidusFriendlyPromotions::Rules::FirstRepeatPurchaseSince,
      Spree::Promotion::Rules::UserRole =>
        SolidusFriendlyPromotions::Rules::UserRole,
      Spree::Promotion::Rules::Store =>
        SolidusFriendlyPromotions::Rules::Store
    },
    actions: {
      Spree::Promotion::Actions::CreateAdjustment => -> (old_action){
        calculator = case old_action.calculator
        when Spree::Calculator::FlatRate
          SolidusFriendlyPromotions::Calculators::DistributedAmount.new(preferences: old_action.calculator.preferences)
        when Spree::Calculator::FlatPercentItemTotal
          SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: old_action.calculator.preferred_flat_percent)
        end

        SolidusFriendlyPromotions::Actions::AdjustLineItem.new(
          calculator: calculator
        )
      },
      Spree::Promotion::Actions::CreateItemAdjustments => ->(old_action) {
        preferences = old_action.calculator.preferences
        calculator = case old_action.calculator
        when Spree::Calculator::FlatRate
          SolidusFriendlyPromotions::Calculators::FlatRate.new(preferences: preferences)
        when Spree::Calculator::PercentOnLineItem
          SolidusFriendlyPromotions::Calculators::Percent.new(preferences: preferences)
        when Spree::Calculator::FlexiRate
          SolidusFriendlyPromotions::Calculators::FlexiRate.new(preferences: preferences)
        when Spree::Calculator::DistributedAmount
          SolidusFriendlyPromotions::Calculators::DistributedAmount.new(preferences: preferences)
        when Spree::Calculator::TieredFlatRate
          SolidusFriendlyPromotions::Calculators::TieredFlatRate.new(preferences: preferences)
        when Spree::Calculator::TieredPercent
          SolidusFriendlyPromotions::Calculators::TieredPercent.new(preferences: preferences)
        end

        SolidusFriendlyPromotions::Actions::AdjustLineItem.new(
          calculator: calculator
        )
      },
      Spree::Promotion::Actions::CreateQuantityAdjustments => nil,
      Spree::Promotion::Actions::FreeShipping => ->(old_action) {
        SolidusFriendlyPromotions::Actions::AdjustShipment.new(
          calculator: SolidusFriendlyPromotions::Calculators::Percent.new(
            preferred_percent: 100
          )
        )
      }
    }
  }
end
