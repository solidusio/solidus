require 'spec_helper'

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
  before { order.update_attributes!(state: 'complete', completed_at: Time.now) }

  subject do
    order.reload
    order.update!
    order.outstanding_balance
  end

  context 'when the order is unpaid' do
    it { should == order.total }
    it { should == 19 }

    context 'when the order is cancelled' do
      before { order.cancel! }
      it { should == 0 }
    end
  end

  context 'when the order is fully paid' do
    let!(:payment) { create(:payment, :completed, order: order, amount: order.total) }
    it { should == 0 }

    context 'and there is a full refund', pending: true do
      let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
      it { should == 19 }
    end

    context 'when the order is cancelled' do
      before { order.update_attributes!(state: "canceled") }
      it { should == -19 }

      context 'and the payment is voided' do
        before { payment.update_attributes!(state: "void") }
        it { should == 0 }
      end

      context 'and there is a full refund', pending: true do
        let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
        it { should == 0 }
      end

      context 'and there is a partial refund', pending: true do
        let!(:refund) { create(:refund, payment: payment, amount: 6) }
        it { should == -13 }
      end
    end

    context 'with a returned item' do
      it 'discounts the returned item amount'

      context 'and there is a full refund' do
        it 'has the correct amount'
      end
    end

    context 'with a cancelled item' do
      let(:cancelations) { Spree::OrderCancellations.new(order) }
      let(:cancelled_item) { order.line_items.first }

      before do
        # Required to refund
        Spree::RefundReason.create!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false)

        cancelations.cancel_unit(cancelled_item.inventory_units.first)
        cancelations.reimburse_units(cancelled_item.inventory_units)

        order.reload
      end

      it 'discounts the cancelled item amount' do
        expect(order.refund_total).to eq(3)
        expect(order.payment_total).to eq(16)
        expect(order.outstanding_balance).to eq(0)

        # Less sure about this one....
        expect(order.total).to eq(19)
      end

      context 'and there is a full refund' do
        it 'has the correct amount'
      end
    end
  end

  context 'when the order is partly paid' do
    let!(:payment) { create(:payment, :completed, order: order, amount: 10) }
    it { should == 9 }

    context 'and there is a full refund', pending: true do
      let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
      it { should == 19 }
    end

    context 'when the order is cancelled' do
      before { order.update_attributes!(state: "canceled") }
      it { should == -10 }

      context 'and the payment is voided' do
        before { payment.update_attributes!(state: "void") }
        it { should == 0 }
      end

      context 'and there is a full refund', pending: true do
        let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }
        it { should == 0 }
      end

      context 'and there is a partial refund', pending: true do
        let!(:refund) { create(:refund, payment: payment, amount: 6) }
        it { should == -4 }
      end
    end
  end
end
