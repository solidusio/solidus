# frozen_string_literal: true

require 'spec_helper'
module Solidus
 describe Solidus::PromotionRulesHelper, type: :helper do
   it "does not include existing rules in options" do
     promotion = Solidus::Promotion.new
     promotion.promotion_rules << Solidus::Promotion::Rules::ItemTotal.new

     options = helper.options_for_promotion_rule_types(promotion)
     expect(options).not_to match(/ItemTotal/)
   end
 end
end
