# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:order) { create(:order_with_line_items) }

  context "#next!" do
    context "when current state is confirm" do
      before do
        order.state = "confirm"
        order.save!
      end

      context "when payment processing succeeds" do
        let!(:payment) do
          create(:payment, state: 'checkout', order: order)
        end

        it "should finalize order when transitioning to complete state" do
          order.complete!
          expect(order).to be_complete
          expect(order).to be_completed
        end

        context "when credit card processing fails" do
          let!(:payment) do
            create(:payment, :failing, state: 'checkout', order: order)
          end

          it "should not complete the order" do
            expect(order.complete).to be false
            expect(order.reload.state).to eq("payment")
          end
        end
      end
    end

    context "when current state is address" do
      before do
        order.ensure_updated_shipments
        order.next!
        expect(order.all_adjustments).to be_empty
        expect(order.state).to eq "address"
      end

      it "adjusts tax rates when transitioning to delivery" do
        expect(Spree::TaxCalculator::Default).to receive(:new).once.with(order).and_call_original
        order.next!
      end
    end
  end

  context "#can_cancel?" do
    let(:order) { create(:completed_order_with_totals) }
    states = [:pending, :backorder, :ready]

    states.each do |shipment_state|
      it "should be true if shipment_state is #{shipment_state}" do
        expect(order).to be_completed
        order.shipment_state = shipment_state

        expect(order).to be_can_cancel
      end
    end

    (Spree::Shipment.state_machine.states.keys - states).each do |shipment_state|
      it "should be false if shipment_state is #{shipment_state}" do
        expect(order).to be_completed
        order.shipment_state = shipment_state
        expect(order).not_to be_can_cancel
      end
    end
  end

  context "#cancel" do
    let!(:order) { create(:completed_order_with_totals) }
    let!(:shipment) { order.shipments.first }

    it "is setup correctly" do
      expect(order).to be_completed
      expect(order).to be_complete
      expect(order).to be_allow_cancel
    end

    it "should send a cancel email" do
      perform_enqueued_jobs do
        order.cancel!
      end

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include "Cancellation"
    end

    it "tries to cancel payments when the order has a complete payment" do
      payment = create(:payment, order: order, amount: order.total, state: "completed")

      expect(payment).to receive(:cancel!)
      expect(order).to be_allow_cancel

      order.cancel!
    end

    it "tries to cancel payments when the order has a pending payment" do
      payment = create(:payment, order: order, amount: order.total, state: "pending")

      expect(payment).to receive(:cancel!)
      expect(order).to be_allow_cancel

      order.cancel!
    end

    it "does not try to cancel payments when the order has a failed payment" do
      payment = create(:payment, order: order, amount: order.total, state: "failed")

      expect(payment).not_to receive(:cancel!)
      expect(order).to be_allow_cancel

      order.cancel!
    end

    it "does not try to cancel payments when the order has shipped shipments" do
      payment = create(:payment, order: order, amount: order.total, state: "completed")
      shipment.ship!

      expect(order).to_not be_allow_cancel
      expect(payment).to_not receive(:cancel!)

      expect(order.cancel).to be_falsey
      expect { order.cancel! }.to raise_error(StateMachines::InvalidTransition)
    end
  end

  describe "#complete" do
    context "when the confirm step has been taken out of the checkout flow" do
      let!(:payment) { create(:payment, state: 'checkout', order: order) }

      before :all do
        class Spree::Order
          checkout_flow do
            go_to_state :address
            go_to_state :delivery
            go_to_state :payment, if: ->(order) { order.payment_required? }
            # confirm step has been removed. Payment is the last step now
          end
        end
      end

      after :all do
        # restore the standard checkout flow to avoid leaking into other tests
        class Spree::Order
          checkout_flow do
            go_to_state :address
            go_to_state :delivery
            go_to_state :payment, if: ->(order) { order.payment_required? }
            go_to_state :confirm
          end
        end
      end

      before do
        order.update!(state: 'payment')
      end

      it 'will properly transition from the last checkout flow state to complete' do
        order.complete!
        expect(order.state).to eq 'complete'
      end
    end
  end
end
