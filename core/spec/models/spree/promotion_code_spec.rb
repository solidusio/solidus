# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PromotionCode do
  context 'callbacks' do
    subject { promotion_code.save }

    describe '#normalize_code' do
      let(:promotion) { create(:promotion, code: code) }
      let(:promotion_code) { promotion.codes.first }

      before { subject }

      context 'with mixed case' do
        let(:code) { 'NewCoDe' }

        it 'downcases the value before saving' do
          expect(promotion_code.value).to eq('newcode')
        end
      end

      context 'with extra spacing' do
        let(:code) { ' new code ' }
        it 'removes surrounding whitespace' do
          expect(promotion_code.value).to eq 'new code'
        end
      end
    end
  end

  describe "#usage_limit_exceeded?" do
    subject { code.usage_limit_exceeded? }

    shared_examples "it should" do
      context "when there is a usage limit" do
        context "and the limit is not exceeded" do
          let(:usage_limit) { 10 }
          it { is_expected.to be_falsy }
        end
        context "and the limit is exceeded" do
          let(:usage_limit) { 1 }
          context "on a different order" do
            before do
              FactoryBot.create(
                :completed_order_with_promotion,
                promotion: promotion
              )
              code.adjustments.update_all(eligible: true)
            end
            it { is_expected.to be_truthy }
          end
          context "on the same order" do
            it { is_expected.to be_falsy }
          end
        end
      end
      context "when there is no usage limit" do
        let(:usage_limit) { nil }
        it { is_expected.to be_falsy }
      end
    end

    let(:code) { promotion.codes.first }

    context "with an order-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :promotion,
          :with_order_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      let(:promotable) do
        FactoryBot.create(
          :completed_order_with_promotion,
          promotion: promotion
        )
      end
      it_behaves_like "it should"
    end

    context "with an item-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :promotion,
          :with_line_item_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      before do
        promotion.actions.first.perform({
          order: order,
          promotion: promotion,
          promotion_code: code
        })
      end
      context "when there are multiple line items" do
        let(:order) { FactoryBot.create(:order_with_line_items, line_items_count: 2) }
        describe "the first item" do
          let(:promotable) { order.line_items.first }
          it_behaves_like "it should"
        end
        describe "the second item" do
          let(:promotable) { order.line_items.last }
          it_behaves_like "it should"
        end
      end
      context "when there is a single line item" do
        let(:order) { FactoryBot.create(:order_with_line_items) }
        let(:promotable) { order.line_items.first }
        it_behaves_like "it should"
      end
    end
  end

  describe "#usage_count" do
    let(:promotion) do
      FactoryBot.create(
        :promotion,
        :with_order_adjustment,
        code: "discount"
      )
    end
    let(:code) { promotion.codes.first }

    subject { code.usage_count }

    context "when the code is applied to a non-complete order" do
      let(:order) { FactoryBot.create(:order_with_line_items) }
      before { promotion.activate(order: order, promotion_code: code) }
      it { is_expected.to eq 0 }
    end
    context "when the code is applied to a complete order" do
      let!(:order) do
        FactoryBot.create(
          :completed_order_with_promotion,
          promotion: promotion
        )
      end
      context "and the promo is eligible" do
        it { is_expected.to eq 1 }
      end
      context "and the promo is ineligible" do
        before { order.adjustments.promotion.update_all(eligible: false) }
        it { is_expected.to eq 0 }
      end
    end
  end

  describe "completing multiple orders with the same code", slow: true do
    let(:promotion) do
      FactoryBot.create(
        :promotion,
        :with_order_adjustment,
        code: "discount",
        per_code_usage_limit: 1,
        weighted_order_adjustment_amount: 10
      )
    end
    let(:code) { promotion.codes.first }
    let(:order) do
      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order: order)
        promotion.activate(order: order, promotion_code: code)
      end
    end
    let(:promo_adjustment) { order.adjustments.promotion.first }
    before do
      order.next! until order.can_complete?

      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order: order)
        promotion.activate(order: order, promotion_code: code)
        order.next! until order.can_complete?
        order.complete!
      end
    end

    it "makes the promotion ineligible" do
      expect{
        order.complete
      }.to change{ promo_adjustment.reload.eligible }.to(false)
    end

    it "adjusts the promo_total" do
      expect{
        order.complete
      }.to change(order, :promo_total).by(10)
    end

    it "increases the total to remove the promo" do
      expect{
        order.complete
      }.to change(order, :total).from(30).to(40)
    end

    it "resets the state of the order" do
      expect{
        order.complete
      }.to change{ order.reload.state }.from("confirm").to("address")
    end
  end
end
