# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Spree::PromotionRule, type: :model do
    class BadTestRule < Spree::PromotionRule; end

    class TestRule < Spree::PromotionRule
      def eligible?(_promotable, _options = {})
        true
      end
    end

    it "forces developer to implement eligible? method" do
      expect { BadTestRule.new.eligible?("promotable") }.to raise_error NotImplementedError
    end

    it "validates unique rules for a promotion" do
      promotion_one = TestRule.new
      promotion_one.promotion_id = 1
      promotion_one.save

      promotion_two = TestRule.new
      promotion_two.promotion_id = 1
      expect(promotion_two).not_to be_valid
    end

    it "generates its own partial path" do
      rule = TestRule.new
      expect(rule.to_partial_path).to eq 'spree/admin/promotions/rules/test_rule'
    end
  end
end
