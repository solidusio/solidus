# frozen_string_literal: true

require "rails_helper"
require "solidus_promotions/promotion_migrator"
require "solidus_promotions/promotion_map"
require "solidus_promotions/migrate_order_promotions"

RSpec.describe SolidusPromotions::MigrateOrderPromotions do
  let(:promotion) { create(:promotion, :with_adjustable_action) }
  let(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:promotion_code) { create(:promotion_code, promotion: promotion) }
  let!(:order_promotion) { order.order_promotions.create!(promotion: promotion, promotion_code: promotion_code) }

  before do
    SolidusPromotions::PromotionMigrator.new(
      SolidusPromotions::PROMOTION_MAP
    ).call
  end

  describe ".up" do
    subject { described_class.up }

    it "deletes the spree order promotion" do
      expect { subject }.to change {
        Spree::OrderPromotion.count
      }.from(1).to(0)
    end

    it "creates our order promotion" do
      expect { subject }.to change {
        SolidusPromotions::OrderPromotion.count
      }.from(0).to(1)

      order_promotion = SolidusPromotions::OrderPromotion.first
      expect(order_promotion.order).to eq(order)
      expect(order_promotion.promotion).to eq(SolidusPromotions::Promotion.first)
      expect(order_promotion.promotion_code.value).to eq(promotion_code.value)
    end

    context "with an order promotion without a promotion code" do
      let!(:order_promotion) { order.order_promotions.create!(promotion: promotion) }

      it "deletes the spree order promotion" do
        expect { subject }.to change {
          Spree::OrderPromotion.count
        }.from(1).to(0)
      end

      it "creates our order promotion" do
        expect { subject }.to change {
          SolidusPromotions::OrderPromotion.count
        }.from(0).to(1)

        order_promotion = SolidusPromotions::OrderPromotion.first
        expect(order_promotion.order).to eq(order)
        expect(order_promotion.promotion).to eq(SolidusPromotions::Promotion.first)
        expect(order_promotion.promotion_code).to be nil
      end

      context "if the order promotion already exists" do
        before do
          order.friendly_order_promotions.create!(
            promotion: SolidusPromotions::Promotion.first,
            promotion_code: nil
          )
        end

        it "deletes the friendly order promotion" do
          expect { subject }.to change {
            Spree::OrderPromotion.count
          }.from(1).to(0)
        end

        it "does not create the already existing spree promotion code" do
          expect { subject }.not_to change {
            SolidusPromotions::OrderPromotion.count
          }.from(1)

          order_promotion = SolidusPromotions::OrderPromotion.last
          expect(order_promotion.order).to eq(order)
          expect(order_promotion.promotion).to eq(SolidusPromotions::Promotion.first)
          expect(order_promotion.promotion_code).to be nil
        end
      end
    end

    context "if the order promotion already exists" do
      before do
        order.friendly_order_promotions.create(
          promotion: SolidusPromotions::Promotion.first,
          promotion_code: SolidusPromotions::PromotionCode.first
        )
      end
      it "deletes the spree order promotion" do
        expect { subject }.to change {
          Spree::OrderPromotion.count
        }.from(1).to(0)
      end

      it "does not create the already existing friendly promotion code" do
        expect { subject }.not_to change {
          SolidusPromotions::OrderPromotion.count
        }.from(1)

        order_promotion = SolidusPromotions::OrderPromotion.first
        expect(order_promotion.order).to eq(order)
        expect(order_promotion.promotion).to eq(SolidusPromotions::Promotion.first)
        expect(order_promotion.promotion_code).to eq(SolidusPromotions::PromotionCode.first)
      end
    end
  end

  describe ".down" do
    subject { described_class.down }

    before do
      described_class.up
    end

    it "creates the spree order promotion" do
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
        SolidusPromotions::OrderPromotion.count
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
          SolidusPromotions::OrderPromotion.count
        }.from(1).to(0)
      end

      context "if the order promotion already exists" do
        before do
          order.order_promotions.create!(
            promotion: promotion,
            promotion_code: nil
          )
        end

        it "deletes the friendly order promotion" do
          expect { subject }.to change {
            SolidusPromotions::OrderPromotion.count
          }.from(1).to(0)
        end

        it "does not create the already existing spree promotion code" do
          expect { subject }.not_to change {
            Spree::OrderPromotion.count
          }.from(1)

          order_promotion = Spree::OrderPromotion.last
          expect(order_promotion.order).to eq(order)
          expect(order_promotion.promotion).to eq(promotion)
          expect(order_promotion.promotion_code).to be nil
        end
      end
    end

    context "if the order promotion already exists" do
      before do
        order.order_promotions.create(
          promotion: promotion,
          promotion_code: promotion_code
        )
      end
      it "deletes the spree order promotion" do
        expect { subject }.to change {
          SolidusPromotions::OrderPromotion.count
        }.from(1).to(0)
      end

      it "does not create the already existing friendly promotion code" do
        expect { subject }.not_to change {
          Spree::OrderPromotion.count
        }.from(1)

        order_promotion = Spree::OrderPromotion.first
        expect(order_promotion.order).to eq(order)
        expect(order_promotion.promotion).to eq(promotion)
        expect(order_promotion.promotion_code).to eq(promotion_code)
      end
    end
  end
end
