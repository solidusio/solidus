# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionRulesHelper, type: :helper do
  it "does not include existing rules in options" do
    promotion = Spree::Promotion.new
    promotion.promotion_rules << Spree::Promotion::Rules::ItemTotal.new

    options = helper.options_for_promotion_rule_types(promotion)
    expect(options).not_to match(/ItemTotal/)
  end
end
