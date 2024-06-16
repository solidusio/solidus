# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::MigrationSupport::OrderPromotionSyncer do
  subject(:syncer) { described_class.new(order: order).call }

  let(:order) { create(:order) }

  context "when there are no friendly order promotions" do
    it "does not create order promotions" do
      expect { subject }.not_to change { order.order_promotions.length }
    end
  end

  context "when there are no order promotions" do
    it "does not create friendly order promotions" do
      expect { subject }.not_to change { order.friendly_order_promotions.length }
    end
  end

  context "when there are spree order promotions" do
    let(:spree_promotion) { create(:promotion) }
    let(:spree_promotion_code) { nil }

    before do
      order.order_promotions.create(
        promotion: spree_promotion,
        promotion_code: spree_promotion_code
      )
    end

    it "does not create friendly order promotions" do
      expect { subject }.not_to change { order.friendly_order_promotions.length }
    end

    context "when there is a corresponding friendly promotion" do
      let!(:friendly_promotion) { create(:friendly_promotion, original_promotion: spree_promotion) }
      let!(:friendly_promotion_code) { nil }

      it "creates a friendly order promotions" do
        expect { subject }.to change { order.friendly_order_promotions.length }.by(1)
        expect(order.friendly_order_promotions.first.promotion).to eq(friendly_promotion)
      end

      it "does not create a friendly order promotion twice" do
        described_class.new(order: order).call
        expect { subject }.not_to change { order.friendly_order_promotions.length }
      end

      context "with a promotion code" do
        let(:spree_promotion_code) { create(:promotion_code, promotion: spree_promotion) }
        let!(:friendly_promotion_code) { create(:friendly_promotion_code, promotion: friendly_promotion, value: spree_promotion_code.value) }

        it "does creates a friendly order promotion with the corresponding code" do
          expect { subject }.to change { order.friendly_order_promotions.length }.by(1)
          expect(order.friendly_order_promotions.first.promotion_code).to eq(friendly_promotion_code)
        end
      end
    end
  end

  context "when there are frienly order promotions" do
    let(:spree_promotion) { nil }
    let(:friendly_promotion) { create(:friendly_promotion, original_promotion: spree_promotion) }
    let(:friendly_promotion_code) { nil }

    before do
      order.friendly_order_promotions.create(
        promotion: friendly_promotion,
        promotion_code: friendly_promotion_code
      )
    end

    it "does not create order promotions" do
      expect { subject }.not_to change { order.order_promotions.length }
    end

    context "when there is a corresponding  promotion" do
      let(:spree_promotion) { create(:promotion) }
      let!(:spree_promotion_code) { nil }

      it "creates a spree order promotion" do
        expect { subject }.to change { order.order_promotions.length }.by(1)
        expect(order.order_promotions.first.promotion).to eq(spree_promotion)
      end

      it "does not create a friendly order promotion twice" do
        described_class.new(order: order).call
        expect { subject }.not_to change { order.order_promotions.length }
      end

      context "with a promotion code" do
        let(:friendly_promotion_code) { create(:friendly_promotion_code, promotion: friendly_promotion) }
        let!(:spree_promotion_code) { create(:promotion_code, promotion: spree_promotion, value: friendly_promotion_code.value) }

        it "does creates a friendly order promotion with the corresponding code" do
          expect { subject }.to change { order.order_promotions.length }.by(1)
          expect(order.order_promotions.first.promotion_code).to eq(spree_promotion_code)
        end
      end
    end
  end
end
