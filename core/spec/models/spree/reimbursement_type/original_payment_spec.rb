# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe ReimbursementType::OriginalPayment, type: :model do
    let(:reimbursement)           { create(:reimbursement, return_items_count: 1) }
    let(:return_item)             { reimbursement.return_items.first }
    let(:payment)                 { reimbursement.order.payments.first }
    let(:simulate)                { false }
    let!(:default_refund_reason)  { Spree::RefundReason.find_or_create_by!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false) }
    let(:created_by_user) { create(:user, email: 'user@email.com') }

    subject { Spree::ReimbursementType::OriginalPayment.reimburse(reimbursement, [return_item], simulate, created_by: created_by_user) }

    before { reimbursement.update!(total: reimbursement.calculated_total) }

    describe ".reimburse" do
      context "simulate is true" do
        let(:simulate) { true }

        it "returns an array of readonly refunds" do
          expect(subject.map(&:class)).to eq [Spree::Refund]
          expect(subject.map(&:readonly?)).to eq [true]
        end
      end

      context "simulate is false" do
        it 'performs the refund' do
          expect {
            subject
          }.to change { payment.refunds.count }.by(1)
          expect(payment.refunds.sum(:amount)).to eq reimbursement.return_items.to_a.sum(&:total)
        end
      end

      context 'when no credit is allowed on the payment' do
        before do
          expect_any_instance_of(Spree::Payment).to receive(:credit_allowed).and_return 0
        end

        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end

      context 'when a payment is negative' do
        before do
          expect_any_instance_of(Spree::Payment).to receive(:amount).and_return(-100)
        end

        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end

      context "multiple payment methods" do
        let(:simulate) { true }
        let!(:check_payment) { create(:check_payment, order: reimbursement.order, amount: 5.0, state: "completed") }
        let(:payment) { reimbursement.order.payments.detect { |item| item.payment_method.is_a? Spree::PaymentMethod::BogusCreditCard } }
        let(:refund_amount) { 10.0 }

        let(:refund_payment_methods) { subject.map { |refund| refund.payment.payment_method } }

        before do
          reimbursement.order.payments.first.update!(amount: 5.0)
          return_item.update!(amount: refund_amount)
        end

        it "includes refunds all payment type" do
          expect(refund_payment_methods).to include payment.payment_method
          expect(refund_payment_methods).to include check_payment.payment_method
        end

        context "filtering payment methods" do
          around do |example|
            original = described_class.eligible_refund_methods
            described_class.eligible_refund_methods = [check_payment.payment_method.class]
            example.run
            described_class.eligible_refund_methods = original
          end

          it "does not refund to ineligible payment methods" do
            expect(refund_payment_methods).to eq [check_payment.payment_method]
          end
        end

        context "sorting payment methods" do
          around do |example|
            original = described_class.eligible_refund_methods
            described_class.eligible_refund_methods = [check_payment.payment_method.class, payment.payment_method.class]
            example.run
            described_class.eligible_refund_methods = original
          end

          it "respects configured payment type sort order" do
            expect(refund_payment_methods).to eq [check_payment.payment_method, payment.payment_method]
          end

          context "only one refund is necessary" do
            let(:refund_amount) { 4.0 }
            it "only returns refunds to satisfy the refund amount" do
              expect(refund_payment_methods).to eq [check_payment.payment_method]
            end
          end
        end
      end
    end
  end
end
