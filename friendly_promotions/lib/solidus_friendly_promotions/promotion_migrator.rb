# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionMigrator
    PROMOTION_IGNORED_ATTRIBUTES = ["id", "type"]

    attr_reader :promotion_map

    def initialize(promotion_map)
      @promotion_map = promotion_map
    end

    def call
      SolidusFriendlyPromotions::Promotion.destroy_all
      Spree::Promotion.all.each do |promotion|
        new_promotion = copy_promotion(promotion)
        new_promotion.rules = promotion.rules.flat_map do |old_promotion_rule|
          generate_new_promotion_rules(old_promotion_rule)
        end
        new_promotion.actions = promotion.actions.flat_map do |old_promotion_action|
          generate_new_promotion_actions(old_promotion_action)
        end
        new_promotion.save!
      end
    end

    private

    def copy_promotion(old_promotion)
      SolidusFriendlyPromotions::Promotion.new(
        old_promotion.attributes.except(*PROMOTION_IGNORED_ATTRIBUTES)
      )
    end

    def generate_new_promotion_actions(old_promotion_action)
      promo_action_config = promotion_map[:actions][old_promotion_action.class]
      if promo_action_config.nil?
        puts("#{old_promotion_action.class} is not supported")
        return []
      end
      promo_action_config.call(old_promotion_action)
    end

    def generate_new_promotion_rules(old_promotion_rule)
      new_promo_rule_class = promotion_map[:rules][old_promotion_rule.class]
      if new_promo_rule_class.nil?
        puts("#{old_promotion_rule.class} is not supported")
        []
      elsif new_promo_rule_class.respond_to?(:call)
        new_promo_rule_class.call(old_promotion_rule)
      else
        new_rule = new_promo_rule_class.new(old_promotion_rule.attributes.except(*PROMOTION_IGNORED_ATTRIBUTES))
        new_rule.preload_relations.each do |relation|
          new_rule.send("#{relation}=", old_promotion_rule.send(relation))
        end
        [new_rule]
      end
    end
  end
end
