# frozen_string_literal: true

module SolidusFriendlyPromotions
  PROMOTION_MAP = {
    conditions: {
      Spree::Promotion::Rules::ItemTotal =>
        SolidusFriendlyPromotions::Conditions::ItemTotal,
      Spree::Promotion::Rules::Product =>
        SolidusFriendlyPromotions::Conditions::Product,
      Spree::Promotion::Rules::User =>
        SolidusFriendlyPromotions::Conditions::User,
      Spree::Promotion::Rules::FirstOrder =>
        SolidusFriendlyPromotions::Conditions::FirstOrder,
      Spree::Promotion::Rules::UserLoggedIn =>
        SolidusFriendlyPromotions::Conditions::UserLoggedIn,
      Spree::Promotion::Rules::OneUsePerUser =>
        SolidusFriendlyPromotions::Conditions::OneUsePerUser,
      Spree::Promotion::Rules::Taxon =>
        SolidusFriendlyPromotions::Conditions::Taxon,
      Spree::Promotion::Rules::NthOrder =>
        SolidusFriendlyPromotions::Conditions::NthOrder,
      Spree::Promotion::Rules::OptionValue =>
        SolidusFriendlyPromotions::Conditions::OptionValue,
      Spree::Promotion::Rules::FirstRepeatPurchaseSince =>
        SolidusFriendlyPromotions::Conditions::FirstRepeatPurchaseSince,
      Spree::Promotion::Rules::UserRole =>
        SolidusFriendlyPromotions::Conditions::UserRole,
      Spree::Promotion::Rules::Store =>
        SolidusFriendlyPromotions::Conditions::Store
    },
    actions: {
      Spree::Promotion::Actions::CreateAdjustment => ->(old_action) {
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
      Spree::Promotion::Actions::CreateQuantityAdjustments => ->(old_action) {
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

        SolidusFriendlyPromotions::Actions::AdjustLineItemQuantityGroups.new(
          preferred_group_size: old_action.preferred_group_size,
          calculator: calculator
        )
      },
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
