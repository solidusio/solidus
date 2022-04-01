# frozen_string_literal: true

class AddLineItemPromotionRulesToExistingPromotions < ActiveRecord::Migration[5.2]
  def up
    Spree::Promotion::Rules::Product.all.each do |promotion_rule|
      match_policy = promotion_rule.preferred_match_policy == "none" ? "inverse" : "normal"
      promotion_rule.promotion.rules << Spree::Promotion::Rules::LineItemProduct.new(
        preferred_match_policy: match_policy,
        products: promotion_rule.products
      )
    end
    Spree::Promotion::Rules::Taxon.all.each do |promotion_rule|
      match_policy = promotion_rule.preferred_match_policy == "none" ? "inverse" : "normal"
      promotion_rule.promotion.rules << Spree::Promotion::Rules::LineItemTaxon.new(
        preferred_match_policy: match_policy,
        taxons: promotion_rule.taxons
      )
    end
    Spree::Promotion::Rules::OptionValue.all.each do |promotion_rule|
      promotion_rule.promotion.rules << Spree::Promotion::Rules::LineItemOptionValue.new(
        preferred_eligible_values: promotion_rule.preferred_eligible_values
      )
    end
  end

  def down
    Spree::Promotion::Rules::LineItemOptionValue.destroy_all
    Spree::Promotion::Rules::LineItemTaxon.destroy_all
    Spree::Promotion::Rules::LineItemProduct.destroy_all
  end
end
