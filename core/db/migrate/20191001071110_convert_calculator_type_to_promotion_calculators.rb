# frozen_string_literal: true

class ConvertCalculatorTypeToPromotionCalculators < ActiveRecord::Migration[5.1]
  DEPRECATED_CALCULATORS = %w[
    DistributedAmount
    FlatPercentItemTotal
    FlatRate
    FlexiRate
    PercentOnLineItem
    PercentPerItem
    PriceSack
    TiredFlatRate
    TiredPercent
  ]

  def up
    DEPRECATED_CALCULATORS.each do |calculator|
      execute("UPDATE spree_calculators "\
               "SET type='Spree::Calculator::Promotion::#{calculator}' "\
               "WHERE type='Spree::Calculator::#{calculator}'")
    end
  end

  def down
    DEPRECATED_CALCULATORS.each do |calculator|
      execute("UPDATE spree_calculators "\
               "SET type='Spree::Calculator::#{calculator}' "\
               "WHERE type='Spree::Calculator::Promotion::#{calculator}'")
    end
  end
end
