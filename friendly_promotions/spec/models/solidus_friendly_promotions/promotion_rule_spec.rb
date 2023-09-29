# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionRule do
  let(:bad_test_rule_class) { Class.new(SolidusFriendlyPromotions::PromotionRule) }
  let(:test_rule_class) do
    Class.new(SolidusFriendlyPromotions::PromotionRule) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "test_rule")
      end

      def eligible?(_promotable, _options = {})
        true
      end
    end
  end

  describe "preferences" do
    subject { described_class.new.preferences }

    it { is_expected.to be_a(Hash) }
  end

  it "forces developer to implement eligible? method" do
    expect { bad_test_rule_class.new.eligible?("promotable") }.to raise_error NotImplementedError
    expect { test_rule_class.new.eligible?("promotable") }.not_to raise_error NotImplementedError
  end

  it "validates unique rules for a promotion" do
    promotion_one = test_rule_class.new
    promotion_one.promotion_id = 1
    promotion_one.save

    promotion_two = test_rule_class.new
    promotion_two.promotion_id = 1
    expect(promotion_two).not_to be_valid
  end

  it "generates its own partial path" do
    rule = test_rule_class.new
    expect(rule.to_partial_path).to eq "solidus_friendly_promotions/admin/promotion_rules/rules/test_rule"
  end
end
