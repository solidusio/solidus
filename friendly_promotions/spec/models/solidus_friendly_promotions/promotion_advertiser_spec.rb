# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionAdvertiser, type: :model do
  describe ".for_product" do
    subject { described_class.for_product(product) }

    let(:product) { create(:product) }
    let!(:promotion) { create(:friendly_promotion, :with_adjustable_action, advertise: true, starts_at: 1.day.ago) }
    let!(:rule) do
      SolidusFriendlyPromotions::Rules::LineItemProduct.create(
        promotion: promotion,
        products: [product]
      )
    end

    it "lists the promotion as a possible promotion" do
      expect(subject).to include(promotion)
    end
  end
end
