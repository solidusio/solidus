# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::EligibilityResults do
  subject(:eligibility_results) { described_class.new(promotion) }

  describe "#add" do
    let(:promotion) { create(:friendly_promotion, :with_adjustable_benefit) }
    let(:promotion_benefit) { promotion.benefits.first }
    let(:order) { create(:order, item_total: 100) }
    let(:condition) { SolidusPromotions::Conditions::ItemTotal.new(benefit: promotion_benefit, preferred_amount: 101) }

    it "can add an error result" do
      result = condition.eligible?(order)

      eligibility_results.add(
        item: order,
        condition: condition,
        success: result,
        code: condition.eligibility_errors.details[:base].first[:error_code],
        message: condition.eligibility_errors.full_messages.first
      )

      expect(eligibility_results.to_a).to eq([
        SolidusPromotions::EligibilityResult.new(
          item: order,
          condition: condition,
          success: result,
          code: condition.eligibility_errors.details[:base].first[:error_code],
          message: condition.eligibility_errors.full_messages.first
        )
      ])
    end
  end
end
