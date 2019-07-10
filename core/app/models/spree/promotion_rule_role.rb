# frozen_string_literal: true

module Spree
  class PromotionRuleRole < ActiveRecord::Base
    belongs_to :promotion_rule, class_name: 'Spree::PromotionRule', optional: true
    belongs_to :role, class_name: 'Spree::Role', optional: true
  end
end
