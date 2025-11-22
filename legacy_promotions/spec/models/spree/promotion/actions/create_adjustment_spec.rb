# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Actions::CreateAdjustment, type: :model do
  let(:order) { create(:order_with_line_items, line_items_count: 1) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::CreateAdjustment.new }
  let(:payload) { { order: } }

  # From promotion spec:
  context "#perform" do
    before do
      action.calculator = Spree::Calculator::FlatRate.new(preferred_amount: 10)
      promotion.promotion_actions = [action]
      allow(action).to receive_messages(promotion:)
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
      let(:payload) { { order:, promotion_code: } }

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

    let!(:unrelated_adjustment) { create(:adjustment, order:, source: nil) }

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

  describe "#available_calculators" do
    subject { action.available_calculators }

    it {
      is_expected.to eq(Spree::Config.promotions.calculators[described_class.to_s])
    }
  end

  describe "#compute_amount" do
    subject { action.compute_amount(order) }

    before do
      promotion.promotion_actions = [action]
      action.calculator = Spree::Calculator::FlatRate.new(preferred_amount:)
    end

    let(:preferred_amount) { 50 }

    context "when the adjustable is actionable" do
      it "calls compute on the calculator" do
        expect(action.calculator).to receive(:compute).with(order).and_call_original
        subject
      end

      it "doesn't persist anything to the database" do
        allow(action.calculator).to receive(:compute).with(order).and_call_original

        expect {
          subject
        }.not_to make_database_queries(manipulative: true)
      end

      context "calculator returns amount greater than order total" do
        let(:preferred_amount) { 300 }

        before do
          allow(order).to receive_messages(item_total: 50, ship_total: 50)
        end

        it "does not exceed it" do
          expect(subject).to eql(-100)
        end
      end
    end
  end
end
