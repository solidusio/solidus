# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionFinder do
  describe ".by_code_or_id" do
    let!(:promotion) { create(:friendly_promotion, code: "promo") }

    it "finds a promotion by its code" do
      expect(described_class.by_code_or_id("promo")).to eq promotion
    end

    it "finds a promotion by its ID" do
      expect(described_class.by_code_or_id(promotion.id)).to eq promotion
    end

    context "when the promotion does not exist" do
      it "raises an error" do
        expect { described_class.by_code_or_id("nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
