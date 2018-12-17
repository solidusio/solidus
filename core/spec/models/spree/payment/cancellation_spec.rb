# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Payment::Cancellation do
  describe '#initialize' do
    it 'has default refund reason' do
      expect(subject.reason).to eq Spree::Payment::Cancellation::DEFAULT_REASON
    end

    context 'with reason given' do
      subject { described_class.new(reason: 'My custom reason') }

      it 'has this as refund reason' do
        expect(subject.reason).to eq 'My custom reason'
      end
    end
  end

  describe '#cancel' do
    subject { described_class.new.cancel(payment) }

    let(:payment_method) { create(:payment_method) }
    let(:payment) { create(:payment, payment_method: payment_method, amount: 10) }

    context 'if the payment_method responds to `try_void`' do
      context 'if payment method returns void response' do
        before do
          expect(payment_method).to receive(:try_void).with(payment) { double }
        end

        it 'handles the void' do
          expect(payment).to receive(:handle_void_response)
          subject
        end
      end

      context 'if payment method rejects the void' do
        before do
          expect(payment_method).to receive(:try_void).with(payment) { false }
        end

        it 'refunds the payment' do
          expect { subject }.to change { payment.refunds.count }.from(0).to(1)
        end

        context 'if payment has partial refunds' do
          let(:credit_amount) { payment.amount / 2 }

          before do
            payment.refunds.create!(
              amount: credit_amount,
              reason: Spree::RefundReason.where(name: 'test').first_or_create
            )
          end

          it 'only refunds the allowed credit amount' do
            subject
            refund = payment.refunds.last
            expect(refund.amount).to eq(credit_amount)
          end
        end
      end
    end

    context 'if the payment_method does not respond to `try_void`', partial_double_verification: false do
      before do
        allow(payment_method).to receive(:respond_to?) { false }
        allow(payment_method).to receive(:cancel) { double }
        allow(payment).to receive(:handle_void_response)
      end

      it 'calls cancel instead' do
        expect(payment_method).to receive(:cancel)
        Spree::Deprecation.silence { subject }
      end

      it 'prints depcrecation warning' do
        expect(Spree::Deprecation).to receive(:warn)
        subject
      end
    end
  end
end
