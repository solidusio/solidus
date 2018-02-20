# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Actions::CreateAdjustment, type: :model do
  let(:order) { create(:order_with_line_items, line_items_count: 1) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::CreateAdjustment.new }
  let(:payload) { { order: order } }

  # From promotion spec:
  context "#perform" do
    before do
      action.calculator = Spree::Calculator::FlatRate.new(preferred_amount: 10)
      promotion.promotion_actions = [action]
      allow(action).to receive_messages(promotion: promotion)
    end

    it "does apply an adjustment if the amount is 0" do
      action.calculator.preferred_amount = 0
      action.perform(payload)
      expect(order.adjustments.count).to eq(1)
    end

    it "should create a discount with correct negative amount" do
      order.shipments.create!(cost: 10)

      action.perform(payload)
      expect(promotion.usage_count).to eq(0)
      expect(order.adjustments.count).to eq(1)
      expect(order.adjustments.first.amount.to_i).to eq(-10)
    end

    it "should create a discount accessible through both order_id and adjustable_id" do
      action.perform(payload)
      expect(order.adjustments.count).to eq(1)
      expect(order.all_adjustments.count).to eq(1)
    end

    it "should not create a discount when order already has one from this promotion" do
      order.shipments.create!(cost: 10)

      action.perform(payload)
      action.perform(payload)
      expect(promotion.usage_count).to eq(0)
      expect(order.adjustments.count).to eq(1)
    end

    context "when a promotion code is used" do
      let(:promotion_code) { create(:promotion_code) }
      let(:promotion) { promotion_code.promotion }
      let(:payload) { { order: order, promotion_code: promotion_code } }

      it "should connect the adjustment to the promotion_code" do
        expect {
          action.perform(payload)
        }.to change { order.adjustments.count }.by(1)
        expect(order.adjustments.last.promotion_code).to eq promotion_code
      end
    end
  end

  describe '#remove_from' do
    let(:action) { promotion.actions.first! }
    let(:promotion) { create(:promotion, :with_order_adjustment) }

    let!(:unrelated_adjustment) { create(:adjustment, order: order, source: nil) }

    before do
      action.perform(payload)
      @action_adjustment = order.adjustments.where(source: action).first!
    end

    it 'removes the action adjustment' do
      expect(order.adjustments).to match_array([unrelated_adjustment, @action_adjustment])

      action.remove_from(order)

      expect(order.adjustments).to eq([unrelated_adjustment])
    end
  end

  shared_examples "destroying adjustments from incomplete orders" do
    before(:each) do
      action.calculator = Spree::Calculator::FlatRate.new(preferred_amount: 10)
      promotion.promotion_actions = [action]
    end

    context "when order is not complete" do
      it "should not keep the adjustment" do
        action.perform(payload)
        subject
        expect(order.adjustments.count).to eq(0)
      end
    end

    context "when order is complete" do
      let(:order) do
        create(:completed_order_with_totals, line_items_count: 1)
      end

      before(:each) do
        action.perform(payload)
        subject
      end

      it "should keep the adjustment" do
        expect(order.adjustments.count).to eq(1)
      end

      it "should nullify the adjustment source" do
        expect(order.adjustments.reload.first.source).to be_nil
      end
    end
  end

  context "#discard" do
    subject { action.discard }
    it_should_behave_like "destroying adjustments from incomplete orders"
  end

  context "#paranoia_destroy" do
    subject { Spree::Deprecation.silence { action.paranoia_destroy } }
    it_should_behave_like "destroying adjustments from incomplete orders"
  end
end
