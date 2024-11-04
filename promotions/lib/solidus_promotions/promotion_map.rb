# frozen_string_literal: true

module SolidusPromotions
  # This constants maps rules and actions from the legacy promotion system to conditions and benefits, respectively.
  # This is used to migrate promotions from the legacy promotion system to the new one.
  # If you have custom rules or actions, you can add them to this hash like so:

  # # lib/my_store/promotion_map.rb
  # require "solidus_promotions/promotion_map"
  #
  # MyStore::PROMOTION_MAP = SolidusPromotions::PROMOTION_MAP.merge(
  #   conditions: {
  #     Spree::Promotion::Rules::MyCustomRule => MyStore::Conditions::MyCustomCondition
  #   },
  #   actions: {
  #     Spree::Promotion::Actions::MyCustomAction => MyStore::Benefits::MyCustomAction
  #   }
  # )

  # And then use it in a custom rake task like so:

  # # lib/rake/my_store.rake
  # namespace :my_store do
  #   desc "Migrate Spree Promotions to Friendly Promotions using a map"
  #   task migrate_existing_promotions: :environment do
  #     require "solidus_promotions/promotion_migrator"
  #     require "my_store/promotion_map"
  #     SolidusPromotions::PromotionMigrator.new(MyStore::PROMOTION_MAP).call
  #   end
  # end

  # Note that the key in both the conditions and actions hash should be the class of the rule or action you want to map, while the value can be either
  # a class or a lambda that returns a class. If you use a lambda, it will be called with the old action or rule as an argument.
  PROMOTION_MAP = {
    conditions: {
      Spree::Promotion::Rules::ItemTotal =>
        SolidusPromotions::Conditions::ItemTotal,
      Spree::Promotion::Rules::Product =>
        SolidusPromotions::Conditions::Product,
      Spree::Promotion::Rules::User =>
        SolidusPromotions::Conditions::User,
      Spree::Promotion::Rules::FirstOrder =>
        SolidusPromotions::Conditions::FirstOrder,
      Spree::Promotion::Rules::UserLoggedIn =>
        SolidusPromotions::Conditions::UserLoggedIn,
      Spree::Promotion::Rules::OneUsePerUser =>
        SolidusPromotions::Conditions::OneUsePerUser,
      Spree::Promotion::Rules::Taxon =>
        SolidusPromotions::Conditions::Taxon,
      Spree::Promotion::Rules::NthOrder =>
        SolidusPromotions::Conditions::NthOrder,
      Spree::Promotion::Rules::OptionValue =>
        SolidusPromotions::Conditions::OptionValue,
      Spree::Promotion::Rules::FirstRepeatPurchaseSince =>
        SolidusPromotions::Conditions::FirstRepeatPurchaseSince,
      Spree::Promotion::Rules::UserRole =>
        SolidusPromotions::Conditions::UserRole,
      Spree::Promotion::Rules::Store =>
        SolidusPromotions::Conditions::Store
    },
    actions: {
      Spree::Promotion::Actions::CreateAdjustment => ->(old_action) {
        calculator = case old_action.calculator
                     when Spree::Calculator::FlatRate
          SolidusPromotions::Calculators::DistributedAmount.new(preferences: old_action.calculator.preferences)
                     when Spree::Calculator::FlatPercentItemTotal
          SolidusPromotions::Calculators::Percent.new(preferred_percent: old_action.calculator.preferred_flat_percent)
        end

        SolidusPromotions::Benefits::AdjustLineItem.new(
          calculator: calculator
        )
      },
      Spree::Promotion::Actions::CreateItemAdjustments => ->(old_action) {
        preferences = old_action.calculator.preferences
        calculator = case old_action.calculator
                     when Spree::Calculator::FlatRate
          SolidusPromotions::Calculators::FlatRate.new(preferences: preferences)
                     when Spree::Calculator::PercentOnLineItem
          SolidusPromotions::Calculators::Percent.new(preferences: preferences)
                     when Spree::Calculator::FlexiRate
          SolidusPromotions::Calculators::FlexiRate.new(preferences: preferences)
                     when Spree::Calculator::DistributedAmount
          SolidusPromotions::Calculators::DistributedAmount.new(preferences: preferences)
                     when Spree::Calculator::TieredFlatRate
          SolidusPromotions::Calculators::TieredFlatRate.new(preferences: preferences)
                     when Spree::Calculator::TieredPercent
          SolidusPromotions::Calculators::TieredPercent.new(preferences: preferences)
        end

        SolidusPromotions::Benefits::AdjustLineItem.new(
          calculator: calculator
        )
      },
      Spree::Promotion::Actions::CreateQuantityAdjustments => ->(old_action) {
        preferences = old_action.calculator.preferences
        calculator = case old_action.calculator
                     when Spree::Calculator::FlatRate
          SolidusPromotions::Calculators::FlatRate.new(preferences: preferences)
                     when Spree::Calculator::PercentOnLineItem
          SolidusPromotions::Calculators::Percent.new(preferences: preferences)
                     when Spree::Calculator::FlexiRate
          SolidusPromotions::Calculators::FlexiRate.new(preferences: preferences)
                     when Spree::Calculator::DistributedAmount
          SolidusPromotions::Calculators::DistributedAmount.new(preferences: preferences)
                     when Spree::Calculator::TieredFlatRate
          SolidusPromotions::Calculators::TieredFlatRate.new(preferences: preferences)
                     when Spree::Calculator::TieredPercent
          SolidusPromotions::Calculators::TieredPercent.new(preferences: preferences)
        end

        SolidusPromotions::Benefits::AdjustLineItemQuantityGroups.new(
          preferred_group_size: old_action.preferred_group_size,
          calculator: calculator
        )
      },
      Spree::Promotion::Actions::FreeShipping => ->(_old_action) {
        SolidusPromotions::Benefits::AdjustShipment.new(
          calculator: SolidusPromotions::Calculators::Percent.new(
            preferred_percent: 100
          )
        )
      }
    }
  }
end
