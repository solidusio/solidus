# frozen_string_literal: true

require 'rails_helper'

# This method in particular has been difficult to get right.
# Many things will affect this amount
#
# See also:
# https://github.com/solidusio/solidus/issues/1254
# https://github.com/spree/spree/issues/6229
# https://github.com/solidusio/solidus/issues/1107
# https://github.com/solidusio/solidus/pull/1557
# https://github.com/solidusio/solidus/pull/1536

RSpec.describe "Outstanding balance integration tests" do
  let!(:order) { create(:order_with_line_items, line_items_count: 2, line_items_price: 3, shipment_cost: 13) }
  let(:item_1) { order.line_items[0] }
  let(:item_2) { order.line_items[1] }
  before { order.update!(state: 'complete', completed_at: Time.now) }

  subject do
    order.reload
    order.recalculate
    order.outstanding_balance
  end

  context 'when the order is unpaid' do
    it { should eq order.total }
    it { should eq 19 }

    context 'when the order is cancelled' do
      before { order.cancel! }
      it { should eq 0 }
    end
  end

  context 'when the order is fully paid' do
    let!(:payment) { create(:payment, :completed, order: order, amount: order.total) }
    it { should eq 0 }

    context 'and there is a full refund' do
      let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
      it { should eq 19 }
    end

    context 'when the order is cancelled' do
      before { order.update!(state: "canceled") }
      it { should eq(-19) }

      context 'and the payment is voided' do
        before { payment.update!(state: "void") }
        it { should eq 0 }
      end

      context 'and there is a full refund' do
        let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
        it { should eq 0 }
      end

      context 'and there is a partial refund' do
        let!(:refund) { create(:refund, payment: payment, amount: 6) }
        it { should eq(-13) }
      end
    end

    context 'with a removed item' do
      before do
        item_amount = item_1.total
        order.contents.remove(item_1.variant)
        create(:refund, payment: payment, amount: item_amount)
      end

      it { should eq(0) }
    end

    context 'when the order is adjusted downward by an admin' do
      let!(:adjustment) { create(:adjustment, order: order, adjustable: item_1, amount: -1, source: nil) }
      let!(:refund) { create(:refund, payment: payment, amount: 1) }

      it { should eq(0) }
    end

    context 'with a cancelled item' do
      let(:cancelations) { Spree::OrderCancellations.new(order) }
      let(:cancelled_item) { item_1 }
      let(:created_by_user) { create(:user, email: 'user@email.com') }

      before do
        # Required to refund
        Spree::RefundReason.create!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false)

        cancelations.cancel_unit(cancelled_item.inventory_units.first)
        cancelations.reimburse_units(cancelled_item.inventory_units, created_by: created_by_user)

        order.reload
      end

      it 'discounts the cancelled item amount' do
        expect(order.refund_total).to eq(3)
        expect(order.reimbursement_total).to eq(3)
        expect(order.payment_total).to eq(16)
        expect(order.outstanding_balance).to eq(0)

        expect(order.total).to eq(19)
      end
    end
  end

  context 'when the order is partly paid' do
    let!(:payment) { create(:payment, :completed, order: order, amount: 10) }
    it { should eq 9 }

    context 'and there is a full refund' do
      let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
      it { should eq 19 }
    end

    context 'when the order is cancelled' do
      before { order.update!(state: "canceled") }
      it { should eq(-10) }

      context 'and the payment is voided' do
        before { payment.update!(state: "void") }
        it { should eq 0 }
      end

      context 'and there is a full refund' do
        let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
        it { should eq 0 }
      end

      context 'and there is a partial refund' do
        let!(:refund) { create(:refund, payment: payment, amount: 6) }
        it { should eq(-4) }
      end
    end
  end
end
