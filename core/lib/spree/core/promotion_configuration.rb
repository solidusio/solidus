# frozen_string_literal: true

module Spree
  module Core
    class PromotionConfiguration
      include Core::EnvironmentExtension

      add_nested_class_set :calculators, default: {
        "Spree::Promotion::Actions::CreateAdjustment" => %w[
          Spree::Calculator::FlatPercentItemTotal
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::TieredPercent
          Spree::Calculator::TieredFlatRate
        ],
        "Spree::Promotion::Actions::CreateItemAdjustments" => %w[
          Spree::Calculator::DistributedAmount
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::TieredPercent
        ],
        "Spree::Promotion::Actions::CreateQuantityAdjustments" => %w[
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::FlatRate
        ]
      }
    end
  end
end
