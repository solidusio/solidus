require 'spec_helper'

describe "order_capturing:capture_payments" do
  include_context(
    'rake',
    task_name: 'order_capturing:capture_payments',
    task_path: Spree::Core::Engine.root.join('lib/tasks/order_capturing.rake'),
  )

  subject { task }

  describe '#prerequisites' do
    subject { super().prerequisites }
    it { is_expected.to include("environment") }
  end
  let(:order) { create(:completed_order_with_pending_payment, line_items_count: 2) }
  let(:payment) { order.payments.first }

  context "with a mix of canceled and shipped inventory" do
    before do
      Spree::OrderCancellations.new(order).short_ship([order.line_items.first.inventory_units.first])
      order.shipping.ship_shipment(order.shipments.first)
      order.update_attributes!(payment_state: 'balance_due')
    end

    it "charges the order" do
      expect(order.inventory_units.any?(&:on_hand?)).to eq false
      expect(order.inventory_units.all? { |iu| iu.canceled? || iu.shipped? }).to eq true
      expect {
        expect { subject.invoke }.to change { payment.reload.state }.to('completed')
      }.to change { order.reload.payment_state }.to('paid')
    end

    context "when there is an error capturing payment" do
      before do
        allow_any_instance_of(Spree::OrderCapturing).to receive(:capture_payments).and_raise(StateMachines::InvalidTransition)
      end

      it "raises a OrderCapturingFailures" do
        expect { subject.invoke }.to raise_error(Spree::OrderCapturingFailures)
      end
    end
  end

  context "with any inventory not shipped or canceled" do
    it "does not charge for the order" do
      expect(order.inventory_units.any?(&:on_hand?)).to eq true
      expect {
        expect { subject.invoke }.not_to change { payment.reload }
      }.not_to change { order.reload.payment_state }
    end
  end
end
