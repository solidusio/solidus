# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Actions::FreeShipping, type: :model do
  let(:order) { create(:completed_order_with_totals) }
  let(:shipment) { order.shipments.to_a.first }
  let(:promotion) { create(:promotion, code: 'somecode', promotion_actions: [action]) }
  let(:action) { Spree::Promotion::Actions::FreeShipping.new }
  let(:payload) { { order: order, promotion_code: promotion_code } }
  let(:promotion_code) { promotion.codes.first! }

  # From promotion spec:
  context "#perform" do
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

    context "when order already has one from this promotion" do
      it "should not create a discount" do
        expect(action.perform(payload)).to be true
        expect(action.perform(payload)).to be false
        expect(promotion.usage_count).to eq(1)
        expect(order.shipment_adjustments.count).to eq(2)
      end
    end
  end

  describe '#remove_from' do
    # this adjustment should not get removed
    let!(:other_adjustment) { create(:adjustment, adjustable: shipment, order: order, source: nil) }

    before do
      action.perform(payload)
      @action_adjustment = shipment.adjustments.where(source: action).first!
    end

    it 'removes the action adjustment' do
      expect(shipment.adjustments).to match_array([other_adjustment, @action_adjustment])

      action.remove_from(order)

      expect(shipment.adjustments).to eq([other_adjustment])
    end
  end
end
