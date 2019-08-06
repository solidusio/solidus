# frozen_string_literal: true

module Spree
  module PromotionRulesHelper
    def options_for_promotion_rule_types(promotion)
      existing = promotion.rules.map { |rule| rule.class.name }
      rules = Rails.application.config.spree.promotions.rules.reject { |rule| existing.include? rule.name }
      options = rules.map { |rule| [rule.model_name.human, rule.name] }
      options_for_select(options)
    end
  end
end
