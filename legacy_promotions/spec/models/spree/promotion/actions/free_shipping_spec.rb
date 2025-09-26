# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Promotion::Actions::FreeShipping, type: :model do
  let(:order) { create(:completed_order_with_totals) }
  let(:shipment) { order.shipments.to_a.first }
  let(:promotion) { create(:promotion, code: "somecode", promotion_actions: [action]) }
  let(:action) { Spree::Promotion::Actions::FreeShipping.new }
  let(:payload) { {order:, promotion_code:} }
  let(:promotion_code) { promotion.codes.first! }

  # From promotion spec:
  describe "#perform" do
    before do
      order.shipments << create(:shipment)
      promotion.promotion_actions << action
    end

    context "when valid" do
      it "should create a discount with correct negative amount" do
        expect(order.shipments.count).to eq(2)
        expect(order.shipments.first.cost).to eq(100)
        expect(order.shipments.last.cost).to eq(100)
        expect(action.perform(payload)).to be true
        expect(promotion.usage_count).to eq(1)
        expect(order.shipment_adjustments.count).to eq(2)
        expect(order.shipment_adjustments.first.amount.to_i).to eq(-100)
        expect(order.shipment_adjustments.last.amount.to_i).to eq(-100)
        expect(order.shipment_adjustments.map(&:promotion_code)).to eq [promotion_code, promotion_code]
      end
    end

    context "when given order is ineligible for promotion" do
      it "does not create any discounts" do
        allow(promotion).to receive(:eligible?).with(order).and_return false

        expect(action.perform(payload)).to be false
        expect(promotion.usage_count).to eq(0)
        expect(order.shipment_adjustments.count).to eq(0)
        expect(order.shipment_adjustments.map(&:promotion_code)).to eq []
      end
    end

    context "when a number of the orders shipments already have free shipping" do
      let(:shipments) { order.shipments }

      context "when all the shipments have free shipping" do
        before do
          shipments.each do |shipment|
            shipment.adjustments.create!(
              order:,
              amount: shipment.cost * -1,
              source: action,
              promotion_code:,
              label: "somelabel"
            )
          end
        end

        it "should not create any more discounts" do
          expect { action.perform(payload) }.not_to change {
            order.shipment_adjustments.count
          }
        end

        it "should return false" do
          expect(action.perform(payload)).to eq(false)
        end
      end

      context "when some of the shipments have free shipping" do
        before do
          shipment = shipments.last

          shipment.adjustments.create!(
            order:,
            amount: shipment.cost * -1,
            source: action,
            promotion_code:,
            label: "somelabel"
          )
        end

        it "should create more discounts" do
          expect { action.perform(payload) }.to change {
            order.shipment_adjustments.count
          }.by(1)
        end

        it "should return true" do
          expect(action.perform(payload)).to eq(true)
        end
      end
    end
  end

  describe "#remove_from" do
    # this adjustment should not get removed
    let!(:other_adjustment) { create(:adjustment, adjustable: shipment, order:, source: nil) }

    before do
      action.perform(payload)
      @action_adjustment = shipment.adjustments.where(source: action).first!
    end

    it "removes the action adjustment" do
      expect(shipment.adjustments).to match_array([other_adjustment, @action_adjustment])

      action.remove_from(order)

      expect(shipment.adjustments).to eq([other_adjustment])
    end
  end

  describe "#available_calculators" do
    subject { action.available_calculators }

    it {
      is_expected.to eq(Spree::Config.promotions.calculators[described_class.to_s])
    }
  end
end
