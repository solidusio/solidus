# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Spree::Order, type: :model do
    let(:order) { stub_model(Spree::Order) }
    let(:updater) { Spree::OrderUpdater.new(order) }

    context "processing payments" do
      let(:order) { create(:order_with_line_items, shipment_cost: 0, line_items_price: 100) }

      before do
        # So that Payment#purchase! is called during processing
        stub_spree_preferences(auto_capture: true)
      end

      let(:payment_method) { create(:credit_card_payment_method) }

      let!(:payment_1) do
        create(:payment, payment_method: payment_method, order: order, amount: 50)
      end

      context 'sharing the same payment method' do
        let!(:payment_2) do
          create(:payment, payment_method: payment_method, order: order, amount: 50)
        end

        it 'processes only new payments' do
          order.process_payments!
          updater.update_payment_state

          expect(order.payment_state).to eq('balance_due')
          expect(order.payment_total).to eq(50)

          expect(payment_1).to be_invalid
          expect(payment_2).to be_completed
        end
      end

      context 'with different payment methods that are store credit' do
        let!(:payment_2) { create(:store_credit_payment, order: order, amount: 50) }

        it 'processes all checkout payments' do
          order.process_payments!
          updater.update_payment_state

          expect(order.payment_state).to eq('paid')
          expect(order.payment_total).to eq(100)

          expect(payment_1).to be_completed
          expect(payment_2).to be_completed
        end

        context 'with over paid payments' do
          let!(:payment_3) { create(:store_credit_payment, order: order, amount: 50) }

          it 'does not go over total for order' do
            order.process_payments!
            updater.update_payment_state

            expect(order.payment_state).to eq('paid')
            expect(order.payment_total).to eq(100)
            expect(payment_1).to be_completed
            expect(payment_2).to be_completed
            expect(payment_3).to be_checkout
          end
        end
      end

      context 'with failed payments' do
        let!(:payment_2) do
          create(:payment,
            payment_method: payment_method,
            order: order,
            amount: 50,
            state: 'failed')
        end

        it "does not use failed payments" do
          expect(payment_1).to receive(:process!).and_call_original
          expect(payment_2).not_to receive(:process!)

          order.process_payments!

          expect(order.payment_total).to eq(50)
        end
      end
    end

    context "with payments completed" do
      it "should not fail transitioning to complete when paid" do
        expect(order).to receive_messages total: 100, payment_total: 100
        expect(order.process_payments!).to be_truthy
      end
    end

    context "ensure source attributes stick around" do
      let(:order){ Spree::Order.create }
      let(:payment_method){ create(:credit_card_payment_method) }
      let(:payment_attributes) do
        {
          payment_method_id: payment_method.id,
          source_attributes: {
            name: "Ryan Bigg",
            number: "41111111111111111111",
            expiry: "01 / 15",
            verification_value: "123"
          }
        }
      end

      it "keeps source attributes on assignment" do
        OrderUpdateAttributes.new(order, payments_attributes: [payment_attributes]).apply
        expect(order.unprocessed_payments.last.source.number).to be_present
      end

      # For the reason of this test, please see spree/spree_gateway#132
      it "keeps source attributes through OrderUpdateAttributes" do
        OrderUpdateAttributes.new(order, payments_attributes: [payment_attributes]).apply
        expect(order.unprocessed_payments.last.source.number).to be_present
      end
    end

    context "checking if order is paid" do
      context "payment_state is paid" do
        before { allow(order).to receive_messages payment_state: 'paid' }
        it { expect(order).to be_paid }
      end

      context "payment_state is credit_owned" do
        before { allow(order).to receive_messages payment_state: 'credit_owed' }
        it { expect(order).to be_paid }
      end
    end

    context "#process_payments!" do
      let(:payment) { stub_model(Spree::Payment) }
      before { allow(order).to receive_messages unprocessed_payments: [payment], total: 10 }

      it "should process the payments" do
        expect(payment).to receive(:process!)
        expect(order.process_payments!).to be_truthy
      end

      context "when a payment raises a GatewayError" do
        before { expect(payment).to receive(:process!).and_raise(Spree::Core::GatewayError) }

        it "should return true when configured to allow checkout on gateway failures" do
          stub_spree_preferences(allow_checkout_on_gateway_error: true)
          expect(order.process_payments!).to be true
        end

        it "should return false when not configured to allow checkout on gateway failures" do
          stub_spree_preferences(allow_checkout_on_gateway_error: false)
          expect(order.process_payments!).to be false
        end
      end
    end

    context "#authorize_payments!" do
      let(:payment) { stub_model(Spree::Payment) }
      before { allow(order).to receive_messages unprocessed_payments: [payment], total: 10 }
      subject { order.authorize_payments! }

      it "processes payments with attempt_authorization!" do
        expect(payment).to receive(:authorize!)
        subject
      end

      it { is_expected.to be_truthy }
    end

    context "#capture_payments!" do
      let(:payment) { stub_model(Spree::Payment) }
      before { allow(order).to receive_messages unprocessed_payments: [payment], total: 10 }
      subject { order.capture_payments! }

      it "processes payments with attempt_authorization!" do
        expect(payment).to receive(:purchase!)
        subject
      end

      it { is_expected.to be_truthy }
    end

    context "#outstanding_balance" do
      it "should return positive amount when payment_total is less than total" do
        order.payment_total = 20.20
        order.total = 30.30
        expect(order.outstanding_balance).to eq(10.10)
      end
      it "should return negative amount when payment_total is greater than total" do
        order.total = 8.20
        order.payment_total = 10.20
        expect(order.outstanding_balance).to be_within(0.001).of(-2.00)
      end

      context "with reimburesements on the order" do
        let(:amount) { 10.0 }
        let(:reimbursement) { create(:reimbursement) }
        let(:order) { reimbursement.order.reload }

        before do
          # Set the payment amount to actually be the order total of 110
          reimbursement.order.payments.first.update_column :amount, amount
          # Creates a refund of 110
          create :refund, amount: amount,
                          payment: reimbursement.order.payments.first,
                          reimbursement: reimbursement
          # Update the order totals so payment_total goes to 0 reflecting the refund..
          order.recalculate
        end

        context "for canceled orders" do
          before { order.update(state: 'canceled') }

          it "it should be zero" do
            expect(order.total).to eq(110)
            expect(order.payments.sum(:amount)).to eq(10)
            expect(order.refund_total).to eq(10)
            expect(order.reimbursement_total).to eq(10)
            expect(order.payment_total).to eq(0)
            expect(order.outstanding_balance).to eq(0)
          end
        end

        context "for non-canceled orders" do
          it 'should incorporate refund reimbursements' do
            # Order Total - (Payment Total + Reimbursed)
            # 110 - (0 + 10) = 100
            expect(order.outstanding_balance).to eq 100
          end
        end
      end
    end

    context "#outstanding_balance?" do
      it "should be true when total greater than payment_total" do
        order.total = 10.10
        order.payment_total = 9.50
        expect(order.outstanding_balance?).to be true
      end
      it "should be true when total less than payment_total" do
        order.total = 8.25
        order.payment_total = 10.44
        expect(order.outstanding_balance?).to be true
      end
      it "should be false when total equals payment_total" do
        order.total = 10.10
        order.payment_total = 10.10
        expect(order.outstanding_balance?).to be false
      end
    end

    context "payment_required?" do
      before { order.total = total }

      context "total is zero" do
        let(:total) { 0 }
        it { expect(order).not_to be_payment_required }
      end

      context "total is once cent" do
        let(:total) { 1 }
        it { expect(order).to be_payment_required }
      end

      context "total is once dollar" do
        let(:total) { 1 }
        it { expect(order).to be_payment_required }
      end

      context "total is huge" do
        let(:total) { 2**32 }
        it { expect(order).to be_payment_required }
      end
    end
  end
end
