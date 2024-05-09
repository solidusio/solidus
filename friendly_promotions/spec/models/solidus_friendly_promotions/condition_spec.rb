# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Condition do
  it { is_expected.to belong_to(:benefit).optional }
  let(:bad_test_condition_class) { Class.new(SolidusFriendlyPromotions::Condition) }
  let(:test_condition_class) do
    Class.new(SolidusFriendlyPromotions::Condition) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "test_condition")
      end

      def eligible?(_promotable, _options = {})
        true
      end
    end
  end

  let(:benefit) { create(:friendly_promotion, :with_adjustable_benefit).benefits.first }

  describe "preferences" do
    subject { described_class.new.preferences }

    it { is_expected.to be_a(Hash) }
  end

  it "forces developer to implement eligible? method" do
    expect { bad_test_condition_class.new.eligible?("promotable") }.to raise_error NotImplementedError
    expect { test_condition_class.new.eligible?("promotable") }.not_to raise_error
  end

  it "validates unique conditions for a promotion benefit" do
    # Because of Rails' STI, we can't use the anonymous class here
    promotion = create(:friendly_promotion, :with_adjustable_benefit)
    promotion_benefit = promotion.benefits.first
    condition_one = SolidusFriendlyPromotions::Conditions::FirstOrder.new(benefit: benefit)
    condition_one.benefit_id = promotion_benefit.id
    condition_one.save!

    condition_two = SolidusFriendlyPromotions::Conditions::FirstOrder.new(benefit: benefit)
    condition_two.benefit_id = promotion_benefit.id
    expect(condition_two).not_to be_valid
    expect(condition_two.errors.full_messages).to include("Benefit already contains this condition type")
  end

  it "generates its own partial path" do
    condition = test_condition_class.new
    expect(condition.to_partial_path).to eq "solidus_friendly_promotions/admin/condition_forms/test_condition"
  end
end
