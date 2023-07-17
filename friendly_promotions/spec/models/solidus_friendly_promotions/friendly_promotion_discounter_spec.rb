# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::FriendlyPromotionDiscounter do
  describe "selecting promotions" do
    let(:order) { create(:order) }
    subject { described_class.new(order) }

    let!(:active_promotion) { create(:friendly_promotion, :with_adjustable_action, apply_automatically: true) }
    let!(:inactive_promotion) { create(:friendly_promotion, :with_adjustable_action, expires_at: 2.days.ago, apply_automatically: true) }
    let!(:connectable_promotion) { create(:friendly_promotion, :with_adjustable_action) }
    let!(:connectable_inactive_promotion) { create(:friendly_promotion, :with_adjustable_action, expires_at: 2.days.ago) }

    context "no promo is connected to the order" do
      it "checks only active promotions" do
        expect(SolidusFriendlyPromotions::PromotionEligibility).to receive(:new).
          with(promotable: order, possible_promotions: [active_promotion]).
          and_call_original
        subject
      end
    end

    context "an active promo is connected to the order" do
      before do
        order.friendly_promotions << connectable_promotion
      end

      it "checks active and connected promotions" do
        expect(SolidusFriendlyPromotions::PromotionEligibility).to receive(:new).
          with(promotable: order, possible_promotions: array_including(active_promotion, connectable_promotion)).
          and_call_original
        subject
      end
    end

    context "an inactive promo is connected to the order" do
      before do
        order.friendly_promotions << connectable_inactive_promotion
      end

      it "does not check connected inactive promotions" do
        expect(SolidusFriendlyPromotions::PromotionEligibility).to receive(:new).
          with(promotable: order, possible_promotions: array_including(active_promotion)).
          and_call_original
        subject
      end
    end
  end
end
