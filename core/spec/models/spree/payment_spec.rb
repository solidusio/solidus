# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Payment, type: :model do
  let(:store) { create :store }
  let(:order) { Spree::Order.create(store: store) }
  let(:refund_reason) { create(:refund_reason) }

  let(:gateway) do
    gateway = Spree::PaymentMethod::BogusCreditCard.new(active: true, name: 'Bogus gateway')
    allow(gateway).to receive_messages(source_required?: true)
    gateway
  end

  let(:avs_code) { 'D' }
  let(:cvv_code) { 'M' }

  let(:card) { create :credit_card }

  let(:payment) do
    Spree::Payment.create! do |payment|
      payment.source = card
      payment.order = order
      payment.payment_method = gateway
      payment.amount = 5
    end
  end

  let(:amount_in_cents) { (payment.amount * 100).round }

  let!(:success_response) do
    ActiveMerchant::Billing::Response.new(true, '', {}, {
      authorization: '123',
      cvv_result: cvv_code,
      avs_result: { code: avs_code }
    })
  end

  let(:failed_response) do
    ActiveMerchant::Billing::Response.new(false, '', {}, {})
  end

  context '.risky' do
    let!(:payment_1) { create(:payment, avs_response: 'Y', cvv_response_code: 'M', cvv_response_message: 'Match') }
    let!(:payment_2) { create(:payment, avs_response: 'Y', cvv_response_code: 'M', cvv_response_message: '') }
    let!(:payment_3) { create(:payment, avs_response: 'A', cvv_response_code: 'M', cvv_response_message: 'Match') }
    let!(:payment_4) { create(:payment, avs_response: 'Y', cvv_response_code: 'N', cvv_response_message: 'No Match') }

    it 'should not return successful responses' do
      expect(subject.class.risky.to_a).to match_array([payment_3, payment_4])
    end
  end

  context "#captured_amount" do
    context "calculates based on capture events" do
      it "with 0 capture events" do
        expect(payment.captured_amount).to eq(0)
      end

      it "with some capture events" do
        payment.save
        payment.capture_events.create!(amount: 2.0)
        payment.capture_events.create!(amount: 3.0)
        expect(payment.captured_amount).to eq(5)
      end
    end
  end

  context '#uncaptured_amount' do
    context "calculates based on capture events" do
      it "with 0 capture events" do
        expect(payment.uncaptured_amount).to eq(5.0)
      end

      it "with some capture events" do
        payment.save
        payment.capture_events.create!(amount: 2.0)
        payment.capture_events.create!(amount: 3.0)
        expect(payment.uncaptured_amount).to eq(0)
      end
    end
  end

  context 'validations' do
    it "returns useful error messages when source is invalid" do
      payment.source = Spree::CreditCard.new
      expect(payment).not_to be_valid
      cc_errors = payment.errors['Credit Card']
      expect(cc_errors).to include("Card Number can't be blank")
      expect(cc_errors).to include("Month is not a number")
      expect(cc_errors).to include("Year is not a number")
      expect(cc_errors).to include("Verification Value can't be blank")
    end
  end

  # Regression test for https://github.com/spree/spree/pull/2224
  context 'failure' do
    it 'should transition to failed from pending state' do
      payment.state = 'pending'
      payment.failure
      expect(payment.state).to eql('failed')
    end

    it 'should transition to failed from processing state' do
      payment.state = 'processing'
      payment.failure
      expect(payment.state).to eql('failed')
    end
  end

  context 'invalidate' do
    it 'should transition from checkout to invalid' do
      payment.state = 'checkout'
      payment.invalidate
      expect(payment.state).to eq('invalid')
    end

    context "the payment's source is invalid" do
      before(:each) do
        card.year = 2014
        payment.source = card
      end

      it "transitions to invalid" do
        payment.state = 'checkout'
        payment.invalidate
        expect(payment.state).to eq 'invalid'
      end
    end
  end

  context "processing" do
    describe "#process!" do
      context 'with autocapture' do
        before do
          payment.payment_method.update!(auto_capture: true)
        end

        it "should purchase" do
          payment.process!
          expect(payment).to be_completed
        end
      end

      context 'without autocapture' do
        before do
          payment.payment_method.update!(auto_capture: false)
        end

        context 'when in the checkout state' do
          before { payment.update!(state: 'checkout') }

          it "authorizes" do
            payment.process!
            expect(payment).to be_pending
          end
        end

        context 'when in the processing state' do
          before { payment.update!(state: 'processing') }

          it "does not authorize" do
            payment.process!
            expect(payment).to be_processing
          end
        end

        context 'when in the pending state' do
          before { payment.update!(state: 'pending') }

          it "does not re-authorize" do
            expect(payment).to_not receive(:authorize!)
            payment.process!
            expect(payment).to be_pending
          end
        end

        context 'when in a failed state' do
          before { payment.update!(state: 'failed') }

          it "raises an exception" do
            expect {
              payment.process!
            }.to raise_error(StateMachines::InvalidTransition, /Cannot transition/)
          end
        end

        context 'when in the completed state' do
          before { payment.update!(state: 'completed') }

          it "authorizes" do
            payment.process!
            # TODO: Is this really what we want to happen in this case?
            expect(payment).to be_pending
          end
        end
      end

      it "should make the state 'processing'" do
        expect(payment).to receive(:started_processing!)
        payment.process!
      end

      it "should invalidate if payment method doesnt support source" do
        expect(payment.payment_method).to receive(:supports?).with(payment.source).and_return(false)
        expect { payment.process! }.to raise_error(Spree::Core::GatewayError)
        expect(payment.state).to eq('invalid')
      end
    end

    describe "#authorize!" do
      it "should call authorize on the gateway with the payment amount" do
        expect(payment.payment_method).to receive(:authorize).with(amount_in_cents,
                                                               card,
                                                               anything).and_return(success_response)
        payment.authorize!
      end

      it "should call authorize on the gateway with the currency code" do
        allow(payment).to receive_messages currency: 'GBP'
        expect(payment.payment_method).to receive(:authorize).with(amount_in_cents,
                                                               card,
                                                               hash_including({ currency: "GBP" })).and_return(success_response)
        payment.authorize!
      end

      it "should log the response" do
        payment.save!
        expect {
          payment.authorize!
        }.to change { payment.log_entries.count }.by(1)
      end

      describe 'billing_address option' do
        context 'when the source is a credit card with an address' do
          let(:card) { create(:credit_card, address: address) }
          let(:address) { create(:address) }

          it 'sends the credit card address' do
            expect(payment.payment_method).to(
              receive(:authorize).
                with(
                  amount_in_cents,
                  card,
                  hash_including(billing_address: card.address.active_merchant_hash)
                ).
                and_return(success_response)
            )
            payment.authorize!
          end
        end

        context 'when the source is a credit card without an address' do
          let(:card) { create(:credit_card, address: nil) }
          before { order.update!(bill_address: address) }
          let(:address) { create(:address) }

          it 'send the order bill address' do
            expect(payment.payment_method).to(
              receive(:authorize).
                with(
                  amount_in_cents,
                  card,
                  hash_including(billing_address: order.bill_address.active_merchant_hash)
                ).
                and_return(success_response)
            )
            payment.authorize!
          end
        end

        context 'when the source is not a credit card' do
          before do
            payment.source = store_credit_payment
            payment.payment_method = store_credit_payment_method
          end

          let(:store_credit_payment) { create(:store_credit_payment) }
          let(:store_credit_payment_method) { create(:store_credit_payment_method) }
          before { order.update!(bill_address: address) }
          let(:address) { create(:address) }

          it 'send the order bill address' do
            expect(payment.payment_method).to(
              receive(:authorize).
                with(
                  amount_in_cents,
                  store_credit_payment,
                  hash_including(billing_address: order.bill_address.active_merchant_hash)
                ).
                and_return(success_response)
            )
            payment.authorize!
          end
        end
      end

      context "if successful" do
        before do
          expect(payment.payment_method).to receive(:authorize).with(amount_in_cents,
                                                                 card,
                                                                 anything).and_return(success_response)
        end

        it "should store the response_code, avs_response and cvv_response fields" do
          payment.authorize!
          expect(payment.response_code).to eq('123')
          expect(payment.avs_response).to eq(avs_code)
          expect(payment.cvv_response_code).to eq(cvv_code)
          expect(payment.cvv_response_message).to eq(ActiveMerchant::Billing::CVVResult::MESSAGES[cvv_code])
        end

        it "should make payment pending" do
          expect(payment).to receive(:pend!)
          payment.authorize!
        end
      end

      context "if unsuccessful" do
        it "should mark payment as failed" do
          allow(gateway).to receive(:authorize).and_return(failed_response)
          expect(payment).to receive(:failure)
          expect(payment).not_to receive(:pend)
          expect {
            payment.authorize!
          }.to raise_error(Spree::Core::GatewayError)
        end
      end
    end

    describe "#purchase!" do
      it "should call purchase on the gateway with the payment amount" do
        expect(gateway).to receive(:purchase).with(amount_in_cents, card, anything).and_return(success_response)
        payment.purchase!
      end

      it "should log the response" do
        payment.save!
        expect {
          payment.purchase!
        }.to change { payment.log_entries.count }.by(1)
      end

      context "if successful" do
        before do
          expect(payment.payment_method).to receive(:purchase).with(amount_in_cents,
                                                                card,
                                                                anything).and_return(success_response)
        end

        it "should store the response_code and avs_response" do
          payment.purchase!
          expect(payment.response_code).to eq('123')
          expect(payment.avs_response).to eq(avs_code)
        end

        it "should make payment complete" do
          expect(payment).to receive(:complete!)
          payment.purchase!
        end

        it "should log a capture event" do
          payment.purchase!
          expect(payment.capture_events.count).to eq(1)
          expect(payment.capture_events.first.amount).to eq(payment.amount)
        end

        it "should set the uncaptured amount to 0" do
          payment.purchase!
          expect(payment.uncaptured_amount).to eq(0)
        end
      end

      context "if unsuccessful" do
        before do
          allow(gateway).to receive(:purchase).and_return(failed_response)
          expect(payment).to receive(:failure)
          expect(payment).not_to receive(:pend)
        end

        it "should make payment failed" do
          expect { payment.purchase! }.to raise_error(Spree::Core::GatewayError)
        end

        it "should not log a capture event" do
          expect { payment.purchase! }.to raise_error(Spree::Core::GatewayError)
          expect(payment.capture_events.count).to eq(0)
        end
      end
    end

    describe "#capture!" do
      context "when payment is pending" do
        before do
          payment.amount = 100
          payment.state = 'pending'
          payment.response_code = '12345'
        end

        context "if successful" do
          context 'for entire amount' do
            before do
              expect(payment.payment_method).to receive(:capture).with(payment.display_amount.money.cents, payment.response_code, anything).and_return(success_response)
            end

            it "should make payment complete" do
              expect(payment).to receive(:complete!)
              payment.capture!
            end

            it "logs capture events" do
              payment.capture!
              expect(payment.capture_events.count).to eq(1)
              expect(payment.capture_events.first.amount).to eq(payment.amount)
            end
          end

          it "logs capture events" do
            payment.capture!
            expect(payment.capture_events.count).to eq(1)
            expect(payment.capture_events.first.amount).to eq(payment.amount)
          end
        end

        context "capturing a partial amount" do
          it "logs capture events" do
            payment.capture!(5000)
            expect(payment.capture_events.count).to eq(1)
            expect(payment.capture_events.first.amount).to eq(50)
          end

          it "stores the captured amount on the payment" do
            payment.capture!(6000)
            expect(payment.captured_amount).to eq(60)
          end

          it "updates the amount of the payment" do
            payment.capture!(6000)
            expect(payment.reload.amount).to eq(60)
          end
        end

        context "if unsuccessful" do
          it "should not make payment complete" do
            allow(gateway).to receive_messages capture: failed_response
            expect(payment).to receive(:failure)
            expect(payment).not_to receive(:complete)
            expect { payment.capture! }.to raise_error(Spree::Core::GatewayError)
          end
        end
      end

      # Regression test for https://github.com/spree/spree/issues/2119
      context "when payment is completed" do
        before do
          payment.state = 'completed'
        end

        it "should do nothing" do
          expect(payment).not_to receive(:complete)
          expect(payment.payment_method).not_to receive(:capture)
          expect(payment.log_entries).not_to receive(:create!)
          payment.capture!
        end
      end
    end

    describe "#cancel!" do
      subject { payment.cancel! }

      before do
        payment.response_code = 'abc'
        payment.state = 'pending'
      end

      context "if void returns successful response" do
        before do
          expect(gateway).to receive(:try_void) { success_response }
        end

        it "should update the state to void" do
          expect { subject }.to change { payment.state }.to('void')
        end

        it "should update the response_code with the authorization from the gateway" do
          expect { subject }.to change { payment.response_code }.to('123')
        end
      end

      context "if void returns failed response" do
        before do
          expect(gateway).to receive(:try_void) { failed_response }
        end

        it "should raise gateway error and not change payment state or response_code", :aggregate_failures do
          expect { subject }.to raise_error(Spree::Core::GatewayError)
          expect(payment.state).to eq('pending')
          expect(payment.response_code).to eq('abc')
        end
      end
    end

    describe "#void_transaction!" do
      before do
        payment.response_code = '123'
        payment.state = 'pending'
      end

      context "when profiles are supported" do
        it "should call payment_gateway.void with the payment's response_code" do
          allow(gateway).to receive_messages payment_profiles_supported?: true
          expect(gateway).to receive(:void).with('123', card, anything).and_return(success_response)
          payment.void_transaction!
        end
      end

      context "when profiles are not supported" do
        it "should call payment_gateway.void with the payment's response_code" do
          allow(gateway).to receive_messages payment_profiles_supported?: false
          expect(gateway).to receive(:void).with('123', anything).and_return(success_response)
          payment.void_transaction!
        end
      end

      it "should log the response" do
        expect {
          payment.void_transaction!
        }.to change { payment.log_entries.count }.by(1)
      end

      context "if successful" do
        it "should update the response_code with the authorization from the gateway" do
          # Change it to something different
          payment.response_code = 'abc'
          payment.void_transaction!
          expect(payment.response_code).to eq('12345')
        end
      end

      context "if unsuccessful" do
        it "should not void the payment" do
          allow(gateway).to receive_messages void: failed_response
          expect(payment).not_to receive(:void)
          expect { payment.void_transaction! }.to raise_error(Spree::Core::GatewayError)
        end
      end

      # Regression test for https://github.com/spree/spree/issues/2119
      context "if payment is already voided" do
        before do
          payment.state = 'void'
        end

        it "should not void the payment" do
          expect(payment.payment_method).not_to receive(:void)
          payment.void_transaction!
        end
      end
    end
  end

  context "when already processing" do
    it "should return nil without trying to process the source" do
      payment.state = 'processing'

      expect(payment.process!).to be_nil
    end
  end

  context "with source required" do
    context "raises an error if no source is specified" do
      before do
        payment.source = nil
      end

      specify do
        expect { payment.process! }.to raise_error(Spree::Core::GatewayError, I18n.t('spree.payment_processing_failed'))
      end
    end
  end

  context "with source optional" do
    context "raises no error if source is not specified" do
      before do
        payment.source = nil
        allow(payment.payment_method).to receive_messages(source_required?: false)
      end

      specify do
        payment.process!
      end
    end
  end

  describe "#credit_allowed" do
    # Regression test for https://github.com/spree/spree/issues/4403 and https://github.com/spree/spree/issues/4407
    it "is the difference between offsets total and payment amount" do
      payment.amount = 100
      allow(payment).to receive(:offsets_total).and_return(0)
      expect(payment.credit_allowed).to eq(100)
      allow(payment).to receive(:offsets_total).and_return(-80)
      expect(payment.credit_allowed).to eq(20)
    end
  end

  describe "#can_credit?" do
    it "is true if credit_allowed > 0" do
      allow(payment).to receive(:credit_allowed).and_return(100)
      expect(payment.can_credit?).to be true
    end

    it "is false if credit_allowed is 0" do
      allow(payment).to receive(:credit_allowed).and_return(0)
      expect(payment.can_credit?).to be false
    end
  end

  describe "#fully_refunded?" do
    subject { payment.fully_refunded? }

    before { payment.amount = 100 }

    context 'before refund' do
      it { is_expected.to be false }
    end

    context 'when refund total equals payment amount' do
      before do
        create(:refund, payment: payment, amount: 50)
        create(:refund, payment: payment, amount: 50)
      end

      it { is_expected.to be true }
    end
  end

  describe "#save" do
    context "captured payments" do
      it "update order payment total" do
        payment = create(:payment, order: order, state: 'completed')
        expect(order.payment_total).to eq payment.amount
      end
    end

    context "not completed payments" do
      it "doesn't update order payment total" do
        expect {
          Spree::Payment.create(amount: 100, order: order)
        }.not_to change { order.payment_total }
      end
    end

    context 'when the payment was completed but now void' do
      let(:payment) do
        Spree::Payment.create(
          amount: 100,
          order: order,
          state: 'completed'
        )
      end

      it 'updates order payment total' do
        payment.void
        expect(order.payment_total).to eq 0
      end
    end

    context "completed orders" do
      let(:payment_method) { create(:check_payment_method) }
      before { allow(order).to receive_messages completed?: true }

      it "updates payment_state and shipments" do
        expect(order.updater).to receive(:update_payment_state)
        expect(order.updater).to receive(:update_shipment_state)
        Spree::Payment.create!(amount: 100, order: order, payment_method: payment_method)
      end
    end

    context "when profiles are supported" do
      before do
        allow(gateway).to receive_messages payment_profiles_supported?: true
        allow(payment.source).to receive_messages has_payment_profile?: false
      end

      context "when there is an error connecting to the gateway" do
        it "should call gateway_error " do
          expect(gateway).to receive(:create_profile).and_raise(ActiveMerchant::ConnectionError.new("foo", nil))
          expect do
            Spree::Payment.create(
              amount: 100,
              order: order,
              source: card,
              payment_method: gateway
            )
          end.to raise_error(Spree::Core::GatewayError)
        end
      end

      context "with multiple payment attempts" do
        let(:attributes) { attributes_for(:credit_card) }

        it "should not try to create profiles on old failed payment attempts" do
          order.payments.destroy_all

          allow_any_instance_of(Spree::Payment).to receive(:payment_method) { gateway }

          Spree::PaymentCreate.new(order, {
            source_attributes: attributes,
            payment_method: gateway,
            amount: 100
          }).build.save!
          expect(gateway).to receive(:create_profile).exactly :once
          expect(order.payments.count).to eq(1)
          Spree::PaymentCreate.new(order, {
            source_attributes: attributes,
            payment_method: gateway,
            amount: 100
          }).build.save!
        end
      end

      context "when successfully connecting to the gateway" do
        it "should create a payment profile" do
          expect(payment.payment_method).to receive :create_profile
          Spree::Payment.create(
            amount: 100,
            order: order,
            source: card,
            payment_method: gateway
          )
        end
      end
    end

    context "when profiles are not supported" do
      before { allow(gateway).to receive_messages payment_profiles_supported?: false }

      it "should not create a payment profile" do
        expect(gateway).not_to receive :create_profile
        Spree::Payment.create(
          amount: 100,
          order: order,
          source: card,
          payment_method: gateway
        )
      end
    end
  end

  describe '#invalidate_old_payments' do
    it 'should not invalidate other payments if not valid' do
      payment.save
      invalid_payment = Spree::Payment.new(amount: 100, order: order, state: 'invalid', payment_method: gateway)
      invalid_payment.save
      expect(payment.reload.state).to eq('checkout')
    end

    context 'with order having other payments' do
      let!(:existing_payment) do
        create(:payment,
          payment_method: existing_payment_method,
          source: existing_payment_source,
          order: order,
          amount: 5)
      end

      let(:payment_method) { create(:payment_method) }
      let(:payment_source) { create(:credit_card) }
      let(:payment) do
        build(:payment,
          payment_method: payment_method,
          source: payment_source,
          order: order,
          amount: 5)
      end

      context 'that are store credit payments' do
        let(:existing_payment_method) { create(:store_credit_payment_method) }
        let(:existing_payment_source) { create(:store_credit) }

        it 'does not invalidate existing payments' do
          expect { payment.save! }.to_not change { order.payments.with_state(:invalid).count }
        end

        context 'when payment itself is a store credit payment' do
          let(:payment_method) { existing_payment_method }
          let(:payment_source) { existing_payment_source }

          it 'does not invalidate existing payments' do
            expect { payment.save! }.to_not change { order.payments.with_state(:invalid).count }
          end
        end
      end

      context 'that are not store credit payments' do
        let(:existing_payment_method) { create(:payment_method) }
        let(:existing_payment_source) { create(:credit_card) }

        it 'invalidates existing payments' do
          expect { payment.save! }.to change { order.payments.with_state(:invalid).count }
        end
      end
    end

    describe "invalidating payments updates in memory objects" do
      let(:payment_method) { create(:check_payment_method) }
      before do
        Spree::PaymentCreate.new(order, amount: 1, payment_method_id: payment_method.id).build.save!
        expect(order.payments.map(&:state)).to contain_exactly(
          'checkout'
        )
        Spree::PaymentCreate.new(order, amount: 2, payment_method_id: payment_method.id).build.save!
      end

      it 'should not have stale payments' do
        expect(order.payments.map(&:state)).to contain_exactly(
          'invalid',
          'checkout'
        )
      end
    end
  end

  # This used to describe #apply_source_attributes, whose behaviour is now part of PaymentCreate
  describe "#apply_source_attributes" do
    context 'with a new source' do
      let(:params) do
        {
          amount: 100,
          payment_method: gateway,
          source_attributes: {
            expiry: "01 / 99",
            number: '1234567890123',
            verification_value: '123',
            name: 'Spree Commerce'
          }
        }
      end

      it "should build the payment's source" do
        payment = Spree::PaymentCreate.new(order, params).build
        expect(payment).to be_valid
        expect(payment.source).not_to be_nil
      end

      it "assigns user and gateway to payment source" do
        order = create(:order)
        payment = Spree::PaymentCreate.new(order, params).build
        source = payment.source

        expect(source.user_id).to eq order.user_id
        expect(source.payment_method_id).to eq gateway.id
      end

      it "errors when payment source not valid" do
        params = { amount: 100, payment_method: gateway,
          source_attributes: { expiry: "1 / 12" } }

        payment = Spree::PaymentCreate.new(order, params).build
        expect(payment).not_to be_valid
        expect(payment.source).not_to be_nil
        expect(payment.source.errors[:number].size).to eq(1)
        expect(payment.source.errors[:verification_value].size).to eq(1)
      end
    end

    context 'with an existing credit card' do
      let(:order) { create(:order, user: user) }
      let(:user) { create(:user) }
      let!(:credit_card) { create(:credit_card, user_id: order.user_id) }
      let!(:wallet_payment_source) { user.wallet.add(credit_card) }

      let(:params) do
        {
          source_attributes: {
            wallet_payment_source_id: wallet_payment_source.id,
            verification_value: '321'
          }
        }
      end

      describe "building a payment" do
        subject do
          Spree::PaymentCreate.new(order, params).build.save!
        end

        it 'sets the existing card as the source for the new payment' do
          expect {
            subject
          }.to change { Spree::Payment.count }.by(1)

          expect(order.payments.last.source).to eq(credit_card)
        end

        it 'sets the payment payment_method to that of the credit card' do
          subject
          expect(order.payments.last.payment_method_id).to eq(credit_card.payment_method_id)
        end

        it 'sets the verification_value on the credit card' do
          subject
          expect(order.payments.last.source.verification_value).to eq('321')
        end

        it 'sets the request_env on the payment' do
          payment = Spree::PaymentCreate.new(order, params.merge(request_env: { 'USER_AGENT' => 'Firefox' })).build
          payment.save!
          expect(payment.request_env).to eq({ 'USER_AGENT' => 'Firefox' })
        end

        context 'the credit card belongs to a different user' do
          let(:other_user) { create(:user) }
          before do
            credit_card.update!(user_id: other_user.id)
            user.wallet.remove(credit_card)
            other_user.wallet.add(credit_card)
          end
          it 'errors' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the credit card has no user' do
          before do
            credit_card.update!(user_id: nil)
            user.wallet.remove(credit_card)
          end
          it 'errors' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the order has no user' do
          before { order.update!(user_id: nil) }
          it 'errors' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the order and the credit card have no user' do
          before do
            order.update!(user_id: nil)
            credit_card.update!(user_id: nil)
          end
          it 'errors' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  describe "#currency" do
    before { allow(order).to receive(:currency) { "ABC" } }
    it "returns the order currency" do
      expect(payment.currency).to eq("ABC")
    end
  end

  describe "#display_amount" do
    it "returns a Spree::Money for this amount" do
      expect(payment.display_amount).to eq(Spree::Money.new(payment.amount))
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2216
  describe "#gateway_options" do
    before { allow(order).to receive_messages(last_ip_address: "192.168.1.1") }

    it "contains an IP" do
      expect(payment.gateway_options[:ip]).to eq(order.last_ip_address)
    end

    it "contains the email address from a persisted order" do
      # Sets the payment's order to a different Ruby object entirely
      payment.order = Spree::Order.find(payment.order_id)
      email = 'foo@example.com'
      order.update(email: email)
      expect(payment.gateway_options[:email]).to eq(email)
    end
  end

  describe "#set_unique_identifier" do
    # Regression test for https://github.com/spree/spree/issues/1998
    it "sets a unique identifier on create" do
      payment.run_callbacks(:create)
      expect(payment.number).not_to be_blank
      expect(payment.number.size).to eq(8)
      expect(payment.number).to be_a(String)
    end

    # Regression test for https://github.com/spree/spree/issues/3733
    it "does not regenerate the identifier on re-save" do
      payment.save!
      old_number = payment.number
      payment.save!
      expect(payment.number).to eq(old_number)
    end

    context "other payment exists" do
      let(:other_payment) {
        payment = Spree::Payment.new
        payment.source = card
        payment.order = order
        payment.payment_method = gateway
        payment
      }

      before { other_payment.save! }

      it "doesn't set duplicate identifier" do
        expect(payment).to receive(:generate_identifier).and_return(other_payment.number)
        expect(payment).to receive(:generate_identifier).and_call_original

        payment.run_callbacks(:create)

        expect(payment.number).not_to be_blank
        expect(payment.number).not_to eq(other_payment.number)
      end
    end
  end

  describe "#amount=" do
    before do
      subject.amount = amount
    end

    context "when the amount is a string" do
      context "amount is a decimal" do
        let(:amount) { '2.99' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.99'))
        end
      end

      context "amount is an integer" do
        let(:amount) { '2' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.0'))
        end
      end

      context "amount contains a dollar sign" do
        let(:amount) { '$2.99' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.99'))
        end
      end

      context "amount contains a comma" do
        let(:amount) { '$2,999.99' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2999.99'))
        end
      end

      context "amount contains a negative sign" do
        let(:amount) { '-2.99' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('-2.99'))
        end
      end

      context "amount is invalid" do
        let(:amount) { 'invalid' }

        # this is a strange default for ActiveRecord

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('0'))
        end
      end

      context "amount is an empty string" do
        let(:amount) { '' }

        it '#amount' do
          expect(subject.amount).to be_nil
        end
      end
    end

    context "when the amount is a number" do
      let(:amount) { 1.55 }

      it '#amount' do
        expect(subject.amount).to eql(BigDecimal('1.55'))
      end
    end

    context "when the locale uses a coma as a decimal separator" do
      before(:each) do
        I18n.backend.store_translations(:fr, { number: { currency: { format: { delimiter: ' ', separator: ',' } } } })
        I18n.locale = :fr
        subject.amount = amount
      end

      after do
        I18n.locale = I18n.default_locale
      end

      context "amount is a decimal" do
        let(:amount) { '2,99' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.99'))
        end
      end

      context "amount contains a $ sign" do
        let(:amount) { '2,99 $' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.99'))
        end
      end

      context "amount is a number" do
        let(:amount) { 2.99 }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.99'))
        end
      end

      context "amount contains a negative sign" do
        let(:amount) { '-2,99 $' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('-2.99'))
        end
      end

      context "amount uses a dot as a decimal separator" do
        let(:amount) { '2.99' }

        it '#amount' do
          expect(subject.amount).to eql(BigDecimal('2.99'))
        end
      end
    end
  end

  describe "is_avs_risky?" do
    it "returns false if avs_response included in NON_RISKY_AVS_CODES" do
      ('A'..'Z').reject{ |x| subject.class::RISKY_AVS_CODES.include?(x) }.to_a.each do |char|
        payment.update_attribute(:avs_response, char)
        expect(payment.is_avs_risky?).to eq false
      end
    end

    it "returns false if avs_response.blank?" do
      payment.update_attribute(:avs_response, nil)
      expect(payment.is_avs_risky?).to eq false
      payment.update_attribute(:avs_response, '')
      expect(payment.is_avs_risky?).to eq false
    end

    it "returns true if avs_response in RISKY_AVS_CODES" do
      # should use avs_response_code helper
      ('A'..'Z').reject{ |x| subject.class::NON_RISKY_AVS_CODES.include?(x) }.to_a.each do |char|
        payment.update_attribute(:avs_response, char)
        expect(payment.is_avs_risky?).to eq true
      end
    end
  end

  describe "is_cvv_risky?" do
    it "returns false if cvv_response_code == 'M'" do
      payment.update_attribute(:cvv_response_code, "M")
      expect(payment.is_cvv_risky?).to eq(false)
    end

    it "returns false if cvv_response_code == nil" do
      payment.update_attribute(:cvv_response_code, nil)
      expect(payment.is_cvv_risky?).to eq(false)
    end

    it "returns false if cvv_response_message == ''" do
      payment.update_attribute(:cvv_response_message, '')
      expect(payment.is_cvv_risky?).to eq(false)
    end

    it "returns true if cvv_response_code == [A-Z], omitting D" do
      # should use cvv_response_code helper
      (%w{N P S U} << "").each do |char|
        payment.update_attribute(:cvv_response_code, char)
        expect(payment.is_cvv_risky?).to eq(true)
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4072 (kinda)
  # The need for this was discovered in the research for https://github.com/spree/spree/issues/4072
  context "state changes" do
    it "are logged to the database" do
      expect(payment.state_changes).to be_empty
      expect(payment.process!).to be true
      expect(payment.state_changes.count).to eq(2)
      changes = payment.state_changes.map { |change| { change.previous_state => change.next_state } }
      expect(changes).to match_array([
        { "checkout" => "processing" },
        { "processing" => "pending" }
      ])
    end
  end

  describe "#actions" do
    let(:source) { Spree::CreditCard.new }
    before { allow(subject).to receive(:payment_source) { source } }

    it "includes the actions that the source can take" do
      allow(source).to receive(:can_capture?) { true }
      expect(subject.actions).to include "capture"
    end

    it "excludes actions that the source cannot take" do
      allow(source).to receive(:can_capture?) { false }
      expect(subject.actions).not_to include "capture"
    end

    it "does not include 'failure' by default" do
      expect(subject.actions).not_to include "failure"
    end

    context "payment state is processing" do
      it "includes the 'failure' action" do
        # because the processing state does not provide
        # clarity about what has happened with an external
        # payment processor, so we want to allow the ability
        # to have someone look at the what happened and determine
        # to mark the payment as having failed
        subject.state = 'processing'
        expect(subject.actions).to include "failure"
      end
    end
  end

  describe "#payment_method" do
    context 'with a soft-deleted payment method' do
      before do
        gateway.save!
        payment.save!
        gateway.discard
      end

      it "works with a soft deleted payment method" do
        expect(payment.reload.payment_method).to eq(gateway)
      end
    end
  end

  describe '::valid scope' do
    before do
      create :payment, state: :void
      create :payment, state: :failed
      create :payment, state: :invalid
    end

    it 'does not include void, failed and invalid payments' do
      expect(described_class.valid).to be_empty
    end
  end
end
