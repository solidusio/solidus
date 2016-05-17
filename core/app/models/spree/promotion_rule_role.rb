module Spree
  class PromotionRuleRole < ActiveRecord::Base
    belongs_to :promotion_rule, class_name: 'Spree::PromotionRule'
    belongs_to :role, class_name: 'Spree::Role'
  end
end
