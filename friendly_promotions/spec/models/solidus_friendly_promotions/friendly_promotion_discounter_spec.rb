# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::FriendlyPromotionDiscounter do
  describe "selecting promotions" do
    subject { described_class.new(order) }

    let(:order) { create(:order) }

    let!(:active_promotion) { create(:friendly_promotion, :with_adjustable_action, apply_automatically: true) }
    let!(:inactive_promotion) do
      create(:friendly_promotion, :with_adjustable_action, expires_at: 2.days.ago, apply_automatically: true)
    end
    let!(:connectable_promotion) { create(:friendly_promotion, :with_adjustable_action) }
    let!(:connectable_inactive_promotion) do
      create(:friendly_promotion, :with_adjustable_action, expires_at: 2.days.ago)
    end

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

  context "promotions in the past" do
    let(:order)  { create(:order, completed_at: 7.days.ago) }
    let(:currently_active_promotion) { create(:friendly_promotion, :with_adjustable_action, starts_at: 1.hour.ago) }
    let(:past_promotion) { create(:friendly_promotion, :with_adjustable_action, starts_at: 1.year.ago, expires_at: 11.months.ago) }
    let(:order_promotion) { create(:friendly_promotion, :with_adjustable_action, starts_at: 8.days.ago, expires_at: 6.days.ago) }

    before do
      order.friendly_promotions << past_promotion
      order.friendly_promotions << order_promotion
      order.friendly_promotions << currently_active_promotion
    end

    subject { described_class.new(order) }

    it "only evaluates the past promotion that was active when the order was completed" do
      expect(subject.promotions).to eq([order_promotion])
    end
  end

  context "shipped orders" do
    let(:order) { create(:order, shipment_state: "shipped") }

    subject { described_class.new(order).call }

    it "returns nil" do
      expect(subject).to be nil
    end
  end
end
