# frozen_string_literal: true

module Solidus
  class PromotionRuleRole < ActiveRecord::Base
    belongs_to :promotion_rule, class_name: 'Solidus::PromotionRule', optional: true
    belongs_to :role, class_name: 'Solidus::Role', optional: true
  end
end
