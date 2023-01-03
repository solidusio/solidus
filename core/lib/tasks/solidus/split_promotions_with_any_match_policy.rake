# frozen_string_literal: true

namespace :solidus do
  desc "Split Promotions with 'any' match policy"
  task split_promotions_with_any_match_policy: :environment do
    Spree::Promotion.where(match_policy: :any).includes(:promotion_rules).all.each do |promotion|
      if promotion.promotion_rules.length <= 1
        promotion.update!(match_policy: :all)
      elsif promotion.active?
        promotion.rules.map do |rule|
          new_promotion = promotion.dup
          new_promotion.promotion_rules = [rule]
          new_promotion.match_policy = "all"
          new_promotion.promotion_actions = promotion.actions.map do |action|
            new_action = action.dup
            if action.respond_to?(:calculator)
              new_action.calculator = action.calculator.dup
            end
            new_action.promotion = new_promotion
            new_action.save!
            new_action
          end
          new_promotion.expires_at = promotion.expires_at
          new_promotion.starts_at = Time.current
          new_promotion.save!
        end
        promotion.update!(expires_at: Time.current)
      end
    end

    Spree::Order.where(completed_at: nil).each { |order| Spree::PromotionHandler::Cart.new(order).activate }
  end
end

