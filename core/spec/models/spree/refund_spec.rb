# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Refund, type: :model do
  let(:amount) { 100.0 }
  let(:amount_in_cents) { amount * 100 }

  let(:payment) { create(:payment, amount: payment_amount, payment_method:) }
  let(:payment_amount) { amount * 2 }
  let(:payment_method) { create(:credit_card_payment_method) }

  let(:refund_reason) { create(:refund_reason) }

  let(:transaction_id) { nil }

  let(:refund) do
    create(
      :refund,
      payment:,
      amount:,
      reason: refund_reason,
      transaction_id:
    )
  end

  describe 'create' do
    subject { refund }

    it "creates a refund record" do
      expect{ subject }.to change { Spree::Refund.count }.by(1)
    end

    it "saves the amount" do
      expect(subject.reload.amount).to eq amount
      expect(subject.money).to be_a(Spree::Money)
    end

    it "does not attempt to process a transaction" do
      expect(subject.transaction_id).to be_nil
    end

    context "with a european price format" do
      let(:amount) { "100,00" }
      let(:payment_amount) { 200.0 }

      before do
        expect(I18n).to receive(:t).with(:'number.currency.format.separator') do
          ","
        end
      end

      it "creates a refund record" do
        expect { subject }.to change { Spree::Refund.count }.by(1)
      end
    end
  end

  describe "#perform!" do
    subject { refund.perform! }

    it "sets #perform_response with the gateway response from the payment provider" do
      expect { subject }.to change { refund.perform_response }.from(nil)

      expect(refund.perform_response).to be_a(ActiveMerchant::Billing::Response)
      expect(refund.perform_response.message).to include(Spree::PaymentMethod::BogusCreditCard::SUCCESS_MESSAGE)
    end

    it "sets a transaction_id" do
      expect { subject }.to change { refund.transaction_id }.from(nil)
    end

    it "adds a Spree::LogEntry" do
      expect { subject }.to change(Spree::LogEntry, :count)
    end

    context "when transaction_id exists" do
      let(:transaction_id) { "12kfjas0" }

      it "maintains the transaction id" do
        expect { subject }.not_to change { refund.transaction_id }
      end

      it "does not attempt to process a transaction" do
        expect(payment.payment_method).not_to receive(:credit)
        subject
      end
    end

    context "when transaction_id is nil" do
      let(:transaction_id) { nil }

      context "processing is successful" do
        it 'creates a refund' do
          expect{ subject }.to change(Spree::Refund, :count).by(1)
        end

        it 'saves the returned authorization value' do
          expect { subject }.to change { refund.reload.transaction_id }.from(nil).to(Spree::PaymentMethod::BogusCreditCard::AUTHORIZATION_CODE)
        end

        it 'saves the passed amount as the refund amount' do
          subject
          expect(refund.reload.amount).to eq amount
        end

        it 'creates a log entry' do
          subject
          expect(refund.reload.log_entries).to be_present
        end

        it "attempts to process a transaction" do
          expect(payment.payment_method).to receive(:credit).once.and_call_original
          subject
        end

        it 'should update the payment total' do
          expect(payment.order).to receive(:recalculate)
          subject
        end
      end

      context "when processing fails" do
        let(:failure_message) { Spree::PaymentMethod::BogusCreditCard::FAILURE_MESSAGE }
        let(:gateway_response) {
          ActiveMerchant::Billing::Response.new(
            false,
            failure_message,
            {},
            test: true,
            authorization: Spree::PaymentMethod::BogusCreditCard::AUTHORIZATION_CODE
          )
        }

        before do
          allow(payment.payment_method)
            .to receive(:credit)
            .with(amount_in_cents, payment.source, payment.transaction_id, { originator: an_instance_of(Spree::Refund) })
            .and_return(gateway_response)
        end


        context 'without performing after create' do
          it 'raises a GatewayError' do
            expect { subject }.to raise_error(Spree::Core::GatewayError, failure_message)
          end
        end
      end

      context 'without payment profiles supported' do
        before do
          allow(payment.payment_method).to receive(:payment_profiles_supported?) { false }
        end

        it 'should not supply the payment source' do
          expect(payment.payment_method)
            .to receive(:credit)
            .with(amount * 100, payment.transaction_id, { originator: an_instance_of(Spree::Refund) })
            .and_call_original

          subject
        end
      end

      context 'with payment profiles supported' do
        before do
          allow(payment.payment_method).to receive(:payment_profiles_supported?) { true }
        end

        it 'should supply the payment source' do
          expect(payment.payment_method)
            .to receive(:credit)
            .with(amount_in_cents, payment.source, payment.transaction_id, { originator: an_instance_of(Spree::Refund) })
            .and_call_original

          subject
        end
      end

      context 'with an activemerchant gateway connection error' do
        before do
          expect(payment.payment_method)
            .to receive(:credit)
            .with(amount_in_cents, payment.source, payment.transaction_id, { originator: an_instance_of(Spree::Refund) })
            .and_raise(ActiveMerchant::ConnectionError.new("foo", nil))
        end

        it 'raises Spree::Core::GatewayError' do
          expect { subject }.to raise_error(Spree::Core::GatewayError, I18n.t('spree.unable_to_connect_to_gateway'))
        end
      end

      context 'with amount too large' do
        let(:payment_amount) { 10 }
        let(:amount) { payment_amount * 2 }

        it 'is invalid' do
          expect { subject }.to raise_error { |error|
            expect(error).to be_a(ActiveRecord::RecordInvalid)
            expect(error.record.errors.full_messages).to eq ["Amount #{I18n.t('activerecord.errors.models.spree/refund.attributes.amount.greater_than_allowed')}"]
          }
        end
      end
    end

    context 'when payment is not present' do
      let(:refund) { build(:refund, payment: nil) }

      it 'returns a validation error' do
        expect { refund.save! }.to raise_error 'Validation failed: Payment can\'t be blank'
      end
    end
  end

  describe 'total_amount_reimbursed_for' do
    let(:customer_return) { reimbursement.customer_return }
    let(:reimbursement) { create(:reimbursement) }
    let!(:default_refund_reason) { Spree::RefundReason.find_or_create_by!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false) }
    let(:created_by_user) { create(:user, email: 'user@email.com') }

    subject { Spree::Refund.total_amount_reimbursed_for(reimbursement) }

    context 'with reimbursements performed' do
      before { reimbursement.perform!(created_by: created_by_user) }

      it 'returns the total amount' do
        amount = Spree::Refund.total_amount_reimbursed_for(reimbursement)
        expect(amount).to be > 0
        expect(amount).to eq reimbursement.total
      end
    end

    context 'without reimbursements performed' do
      it 'returns zero' do
        amount = Spree::Refund.total_amount_reimbursed_for(reimbursement)
        expect(amount).to eq 0
      end
    end

    describe "metadata fields" do
      it "responds to public_metadata" do
        expect(refund).to respond_to(:public_metadata)
      end

      it "responds to private_metadata" do
        expect(refund).to respond_to(:private_metadata)
      end

      it "can store data in public_metadata" do
        refund.public_metadata = { "refund_reason" => "price_adjustment" }
        expect(refund.public_metadata["refund_reason"]).to eq("price_adjustment")
      end

      it "can store data in private_metadata" do
        refund.private_metadata = { "internal_notes" => "Refund processed manually" }
        expect(refund.private_metadata["internal_notes"]).to eq("Refund processed manually")
      end
    end
  end
end
