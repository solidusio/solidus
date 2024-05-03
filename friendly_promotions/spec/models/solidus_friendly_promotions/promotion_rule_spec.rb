# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionRule do
  it { is_expected.to belong_to(:action).optional }
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
    expect { test_rule_class.new.eligible?("promotable") }.not_to raise_error
  end

  it "validates unique rules for a promotion action" do
    # Because of Rails' STI, we can't use the anonymous class here
    promotion = create(:friendly_promotion, :with_adjustable_action)
    promotion_action = promotion.actions.first
    rule_one = SolidusFriendlyPromotions::Rules::FirstOrder.new
    rule_one.action_id = promotion_action.id
    rule_one.save!

    rule_two = SolidusFriendlyPromotions::Rules::FirstOrder.new
    rule_two.action_id = promotion_action.id
    expect(rule_two).not_to be_valid
    expect(rule_two.errors.full_messages).to include("Promotion already contains this rule type")
  end

  it "generates its own partial path" do
    rule = test_rule_class.new
    expect(rule.to_partial_path).to eq "solidus_friendly_promotions/admin/promotion_rules/rules/test_rule"
  end
end
