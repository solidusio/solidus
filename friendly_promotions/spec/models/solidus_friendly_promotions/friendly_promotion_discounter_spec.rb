# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::FriendlyPromotionDiscounter do
  context "shipped orders" do
    let(:order) { create(:order, shipment_state: "shipped") }

    subject { described_class.new(order).call }

    it "returns the order unmodified" do
      expect(order).not_to receive(:reset_current_discounts)
      expect(subject).to eq(order)
    end
  end
end
