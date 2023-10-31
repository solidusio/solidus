# frozen_string_literal: true

require "spec_helper"
require "solidus_friendly_promotions/promotion_migrator"
require "solidus_friendly_promotions/promotion_map"
require "solidus_friendly_promotions/migrate_order_promotions"

RSpec.describe SolidusFriendlyPromotions::MigrateOrderPromotions do
  let(:promotion) { create(:promotion, :with_adjustable_action) }
  let(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:promotion_code) { create(:promotion_code, promotion: promotion) }
  let!(:order_promotion) { order.order_promotions.create!(promotion: promotion, promotion_code: promotion_code) }

  before do
    SolidusFriendlyPromotions::PromotionMigrator.new(
      SolidusFriendlyPromotions::PROMOTION_MAP
    ).call
  end

  describe ".up" do
    subject { described_class.up }

    it "migrates our order promotion" do
      expect { subject }.to change {
        Spree::OrderPromotion.count
      }.from(1).to(0)
    end

    it "creates our order promotion" do
      expect { subject }.to change {
        SolidusFriendlyPromotions::OrderPromotion.count
      }.from(0).to(1)

      order_promotion = SolidusFriendlyPromotions::OrderPromotion.first
      expect(order_promotion.order).to eq(order)
      expect(order_promotion.promotion).to eq(SolidusFriendlyPromotions::Promotion.first)
      expect(order_promotion.promotion_code.value).to eq(promotion_code.value)
    end

    context "with an order promotion without a promotion code" do
      let!(:order_promotion) { order.order_promotions.create!(promotion: promotion) }

      it "migrates our order promotion" do
        expect { subject }.to change {
          Spree::OrderPromotion.count
        }.from(1).to(0)
      end

      it "creates our order promotion" do
        expect { subject }.to change {
          SolidusFriendlyPromotions::OrderPromotion.count
        }.from(0).to(1)

        order_promotion = SolidusFriendlyPromotions::OrderPromotion.first
        expect(order_promotion.order).to eq(order)
        expect(order_promotion.promotion).to eq(SolidusFriendlyPromotions::Promotion.first)
        expect(order_promotion.promotion_code).to be nil
      end
    end
  end

  describe ".down" do
    subject { described_class.down }

    before do
      described_class.up
    end

    it "migrates our order promotion" do
      expect { subject }.to change {
        Spree::OrderPromotion.count
      }.from(0).to(1)

      order_promotion = Spree::OrderPromotion.first
      expect(order_promotion.order).to eq(order)
      expect(order_promotion.promotion).to eq(promotion)
      expect(order_promotion.promotion_code).to eq(promotion_code)
    end

    it "creates our order promotion" do
      expect { subject }.to change {
        SolidusFriendlyPromotions::OrderPromotion.count
      }.from(1).to(0)
    end

    context "with an order promotion without a promotion code" do
      let!(:order_promotion) { order.order_promotions.create!(promotion: promotion) }

      it "migrates our order promotion" do
        expect { subject }.to change {
          Spree::OrderPromotion.count
        }.from(0).to(1)
        order_promotion = Spree::OrderPromotion.first
        expect(order_promotion.order).to eq(order)
        expect(order_promotion.promotion).to eq(Spree::Promotion.first)
        expect(order_promotion.promotion_code).to be nil
      end

      it "creates our order promotion" do
        expect { subject }.to change {
          SolidusFriendlyPromotions::OrderPromotion.count
        }.from(1).to(0)
      end
    end
  end
end
