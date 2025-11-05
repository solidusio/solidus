# frozen_string_literal: true

class SeparateOutOrderOnlyConditions < ActiveRecord::Migration[7.0]
  def up
    order_only_conditions = SolidusPromotions::Condition.all.select do |condition|
      condition.respond_to?(:preferred_line_item_applicable) && condition.preferred_line_item_applicable == false
    end

    order_only_conditions.each do |condition|
      case condition
      when SolidusPromotions::Conditions::Product
        condition.type = "SolidusPromotions::Conditions::OrderProduct"
        condition.preferences.delete(:preferred_line_item_applicable)
        condition.save!
      when SolidusPromotions::Conditions::Taxon
        condition.type = "SolidusPromotions::Conditions::OrderTaxon"
        condition.preferences.delete(:preferred_line_item_applicable)
        condition.save!
      when SolidusPromotions::Conditions::OptionValue
        condition.type = "SolidusPromotions::Conditions::OrderOptionValue"
        condition.preferences.delete(:preferred_line_item_applicable)
        condition.save!
      else
        raise NotImplementedError, <<~MSG
          Please create a new condition that is only applicable to orders for #{condition.class}
          and update the corresponding record on the #{condition.benefit.promotion.name} Promotion.
        MSG
      end
    end

    SolidusPromotions::Condition.all.select do |condition|
      condition.preferences[:preferred_line_item_applicable]
    end.each do |condition|
      condition.preferences.delete(:preferred_line_item_applicable)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
