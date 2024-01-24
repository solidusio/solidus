# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::FriendlyPromotionAdjuster::LoadPromotions do
  describe "selecting promotions" do
    subject { described_class.new(order: order).call }

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
      it "returns only active promotions" do
        expect(subject).to eq([active_promotion])
      end
    end

    context "an active promo is connected to the order" do
      before do
        order.friendly_promotions << connectable_promotion
      end

      it "checks active and connected promotions" do
        expect(subject).to include(active_promotion, connectable_promotion)
      end
    end

    context "an inactive promo is connected to the order" do
      before do
        order.friendly_promotions << connectable_inactive_promotion
      end

      it "does not check connected inactive promotions" do
        expect(subject).not_to include(connectable_inactive_promotion)
        expect(subject).to eq([active_promotion])
      end
    end

    context "discarded promotions" do
      let!(:discarded_promotion) { create(:friendly_promotion, :with_adjustable_action, deleted_at: 1.hour.ago, apply_automatically: true) }

      it "does not check discarded promotions" do
        expect(subject).not_to include(discarded_promotion)
      end

      context "a discarded promo is connected to the order" do
        before do
          order.friendly_promotions << discarded_promotion
        end

        it "does not check connected discarded promotions" do
          expect(subject).not_to include(discarded_promotion)
          expect(subject).to eq([active_promotion])
        end
      end
    end
  end

  context "promotions in the past" do
    let(:order) { create(:order, completed_at: 7.days.ago) }
    let(:currently_active_promotion) { create(:friendly_promotion, :with_adjustable_action, starts_at: 1.hour.ago) }
    let(:past_promotion) { create(:friendly_promotion, :with_adjustable_action, starts_at: 1.year.ago, expires_at: 11.months.ago) }
    let(:order_promotion) { create(:friendly_promotion, :with_adjustable_action, starts_at: 8.days.ago, expires_at: 6.days.ago) }

    before do
      order.friendly_promotions << past_promotion
      order.friendly_promotions << order_promotion
      order.friendly_promotions << currently_active_promotion
    end

    subject { described_class.new(order: order).call }

    it "only evaluates the past promotion that was active when the order was completed" do
      expect(subject).to eq([order_promotion])
    end
  end
end
