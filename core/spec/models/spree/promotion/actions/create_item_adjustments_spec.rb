# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Promotion::Actions::CreateItemAdjustments, type: :model do
    let(:order) { create(:order_with_line_items, line_items_count: 1) }
    let(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: adjustment_amount) }
    let(:adjustment_amount) { 10 }
    let(:action) { promotion.actions.first! }
    let(:line_item) { order.line_items.to_a.first }
    let(:payload) { { order: order, promotion: promotion } }

    before do
      allow(action).to receive(:promotion).and_return(promotion)
      promotion.promotion_actions = [action]
    end

    context "#perform" do
      # Regression test for https://github.com/spree/spree/issues/3966
      context "when calculator computes 0" do
        let(:adjustment_amount) { 0 }

        it "does not create an adjustment when calculator returns 0" do
          action.perform(payload)
          expect(action.adjustments).to be_empty
        end
      end

      context "when calculator returns a non-zero value" do
        let(:adjustment_amount) { 10 }

        it "creates adjustment with item as adjustable" do
          action.perform(payload)
          expect(action.adjustments.count).to eq(1)
          expect(line_item.adjustments).to eq(action.adjustments)
        end

        it "creates adjustment with self as source" do
          action.perform(payload)
          expect(line_item.adjustments.first.source).to eq action
        end

        it "does not perform twice on the same item" do
          2.times { action.perform(payload) }
          expect(action.adjustments.count).to eq(1)
        end

        context "with products rules" do
          let(:rule) { double Spree::Promotion::Rules::Product }

          before { allow(promotion).to receive(:eligible_rules) { [rule] } }

          context "when the rule is actionable" do
            before { allow(rule).to receive(:actionable?).and_return(true) }

            it "creates an adjustment" do
              expect {
                expect {
                  action.perform(payload)
                }.to change { action.adjustments.count }.by(1)
              }.to change { line_item.adjustments.count }.by(1)

              expect(action.adjustments.last).to eq line_item.adjustments.last
            end
          end

          context "when the rule is not actionable" do
            before { allow(rule).to receive(:actionable?).and_return(false) }

            it "does not create an adjustment" do
              expect {
                expect {
                  action.perform(payload)
                }.to_not change { action.adjustments.count }
              }.to_not change { line_item.adjustments.count }
            end
          end
        end

        context "when a promotion code is used" do
          let!(:promotion_code) { create(:promotion_code, promotion: promotion) }
          let(:payload) { { order: order, promotion: promotion, promotion_code: promotion_code } }

          it "should connect the adjustment to the promotion_code" do
            expect {
              action.perform(payload)
            }.to change { line_item.adjustments.count }.by(1)
            expect(line_item.adjustments.last.promotion_code).to eq promotion_code
          end
        end
      end
    end

    context "#compute_amount" do
      before { promotion.promotion_actions = [action] }

      context "when the adjustable is actionable" do
        it "calls compute on the calculator" do
          expect(action.calculator).to receive(:compute).with(line_item).and_call_original
          action.compute_amount(line_item)
        end

        context "calculator returns amount greater than item total" do
          before do
            action.calculator.preferred_amount = 300
            allow(line_item).to receive_messages(amount: 100)
          end

          it "does not exceed it" do
            expect(action.compute_amount(line_item)).to eql(-100)
          end
        end
      end

      context "when the adjustable is not actionable" do
        before { allow(promotion).to receive(:line_item_actionable?) { false } }

        it 'returns 0' do
          expect(action.compute_amount(line_item)).to eql(0)
        end
      end
    end

    describe '#remove_from' do
      # this adjustment should not get removed
      let!(:other_adjustment) { create(:adjustment, adjustable: line_item, order: order, source: nil) }

      before do
        action.perform(payload)
        @action_adjustment = line_item.adjustments.where(source: action).first!
      end

      it 'removes the action adjustment' do
        expect(line_item.adjustments).to match_array([other_adjustment, @action_adjustment])

        action.remove_from(order)

        expect(line_item.adjustments).to eq([other_adjustment])
      end
    end

    shared_examples "destroying adjustments from incomplete orders" do
      let!(:action) { promotion.actions.first }
      let(:other_action) { other_promotion.actions.first }
      let(:promotion) { create(:promotion, :with_line_item_adjustment) }
      let(:other_promotion) { create(:promotion, :with_line_item_adjustment) }

      context 'with incomplete orders' do
        let(:order) { create(:order) }

        it 'destroys adjustments' do
          order.adjustments.create!(label: 'Check', amount: 0, order: order, source: action)

          expect {
            subject
          }.to change { Adjustment.count }.by(-1)
        end
      end

      context 'with complete orders' do
        let(:order) { create(:completed_order_with_totals) }

        it "does not change adjustments for completed orders" do
          order = create :order, completed_at: Time.current
          adjustment = action.adjustments.create!(label: "Check", amount: 0, order: order, adjustable: order)

          expect {
            expect {
              subject
            }.not_to change { adjustment.reload.source_id }
          }.not_to change { Spree::Adjustment.count }

          expect(adjustment.source).to eq(nil)
          expect(Spree::PromotionAction.with_deleted.find(adjustment.source_id)).to be_present
        end

        it "doesnt mess with unrelated adjustments" do
          order.adjustments.create!(label: "Check", amount: 0, order: order, source: action)

          expect {
            subject
          }.not_to change { other_action.adjustments.count }
        end
      end
    end

    describe "#discard" do
      subject { action.discard }
      it_should_behave_like "destroying adjustments from incomplete orders"
    end

    describe "#paranoia_destroy" do
      subject { Spree::Deprecation.silence { action.paranoia_destroy } }
      it_should_behave_like "destroying adjustments from incomplete orders"
    end
  end
end
