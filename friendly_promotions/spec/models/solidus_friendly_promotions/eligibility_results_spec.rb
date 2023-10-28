# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::EligibilityResults do
  subject(:eligibility_results) { described_class.new(promotion) }

  describe "#add" do
    let(:promotion) { create(:friendly_promotion) }
    let(:order) { create(:order, item_total: 100) }
    let(:rule) { SolidusFriendlyPromotions::Rules::ItemTotal.new(promotion: promotion, preferred_amount: 101) }

    it "can add an error result" do
      result = rule.eligible?(order)

      eligibility_results.add(
        item: order,
        rule: rule,
        success: result,
        code: rule.eligibility_errors.details[:base].first[:error_code],
        message: rule.eligibility_errors.full_messages.first
      )

      expect(eligibility_results.to_a).to eq([
        SolidusFriendlyPromotions::EligibilityResult.new(
          item: order,
          rule: rule,
          success: result,
          code: rule.eligibility_errors.details[:base].first[:error_code],
          message: rule.eligibility_errors.full_messages.first
        )
      ])
    end
  end
end
