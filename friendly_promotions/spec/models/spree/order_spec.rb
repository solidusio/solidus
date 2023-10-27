# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::Order do
  it { is_expected.to have_many :friendly_promotions }
  it { is_expected.to have_many :friendly_order_promotions }

  describe "#reset_current_discounts" do
    let(:line_item) { Spree::LineItem.new }
    let(:shipment) { Spree::Shipment.new }
    let(:order) { Spree::Order.new(shipments: [shipment], line_items: [line_item]) }

    subject { order.reset_current_discounts }

    it "resets the current discounts on all line items and shipments" do
      expect(line_item).to receive(:reset_current_discounts)
      expect(shipment).to receive(:reset_current_discounts)
      subject
    end
  end

  describe "order deletion" do
    let(:order) { create(:order) }
    let(:promotion) { create(:friendly_promotion) }

    subject { order.destroy }
    before do
      order.friendly_promotions << promotion
    end

    it "deletes join table entries when deleting an order" do
      expect { subject }.to change { SolidusFriendlyPromotions::OrderPromotion.count }.from(1).to(0)
    end
  end

  describe "#apply_shipping_promotions" do
    let(:order) { build(:order) }
    subject { order.apply_shipping_promotions }

    it "does not call Spree::PromotionHandler::Shipping" do
      expect(Spree::PromotionHandler::Shipping).not_to receive(:new)
      subject
    end

    context "if solidus_friendly_promotions is not active" do
      around do |example|
        Spree::Config.promotion_adjuster_class = Spree::Promotion::OrderAdjustmentsRecalculator
        example.run
        Spree::Config.promotion_adjuster_class = SolidusFriendlyPromotions::OrderDiscounter
      end

      it "does call the promotion handler shipping" do
        expect(Spree::PromotionHandler::Shipping).to receive(:new).and_call_original
        subject
      end
    end
  end
end
