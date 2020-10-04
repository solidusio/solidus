# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PaymentMethod::StoreCredit do
  let(:order)           { create(:order) }
  let(:payment)         { create(:payment, order: order) }
  let(:gateway_options) { payment.gateway_options }

  context "#authorize" do
    subject do
      Spree::PaymentMethod::StoreCredit.new.authorize(auth_amount, store_credit, gateway_options)
    end

    let(:auth_amount) { store_credit.amount_remaining * 100 }
    let(:store_credit) { create(:store_credit) }
    let(:gateway_options) { super().merge(originator: originator) }
    let(:originator) { nil }

    context 'without an invalid store credit' do
      let(:store_credit) { nil }
      let(:auth_amount) { 10 }

      it "declines an unknown store credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.unable_to_find')
      end
    end

    context 'with insuffient funds' do
      let(:auth_amount) { (store_credit.amount_remaining * 100) + 1 }

      it "declines a store credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.insufficient_funds')
      end
    end

    context 'when the currency does not match the order currency' do
      let(:store_credit) { create(:store_credit, currency: 'AUD') }

      it "declines the credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.currency_mismatch')
      end
    end

    context 'with a valid request' do
      it "authorizes a valid store credit" do
        expect(subject.success?).to be true
        expect(subject.authorization).not_to be_nil
      end

      context 'with an originator' do
        let(:originator) { double('originator') }

        it 'passes the originator' do
          expect_any_instance_of(Spree::StoreCredit).to receive(:authorize)
            .with(anything, anything, action_originator: originator)
          subject
        end
      end
    end
  end

  context "#capture" do
    subject do
      Spree::PaymentMethod::StoreCredit.new.capture(capture_amount, auth_code, gateway_options)
    end

    let(:capture_amount) { 10_00 }
    let(:auth_code) { auth_event.authorization_code }
    let(:gateway_options) { super().merge(originator: originator) }

    let(:authorized_amount) { capture_amount / 100.0 }
    let(:auth_event) { create(:store_credit_auth_event, store_credit: store_credit, amount: authorized_amount) }
    let(:store_credit) { create(:store_credit, amount_authorized: authorized_amount) }
    let(:originator) { nil }

    context 'with an invalid auth code' do
      let(:auth_code) { -1 }

      it "declines an unknown store credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.unable_to_find')
      end
    end

    context 'when unable to authorize the amount' do
      let(:authorized_amount) { (capture_amount - 1) / 100 }

      before do
        allow_any_instance_of(Spree::StoreCredit).to receive_messages(authorize: true)
      end

      it "declines a store credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.insufficient_authorized_amount')
      end
    end

    context 'when the currency does not match the order currency' do
      let(:store_credit) { create(:store_credit, currency: 'AUD', amount_authorized: authorized_amount) }

      it "declines the credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.currency_mismatch')
      end
    end

    context 'with a valid request' do
      it "captures the store credit" do
        expect(subject.message).to include I18n.t('spree.store_credit.successful_action', action: Spree::StoreCredit::CAPTURE_ACTION)
        expect(subject.success?).to be true
      end

      context 'with an originator' do
        let(:originator) { double('originator') }

        it 'passes the originator' do
          expect_any_instance_of(Spree::StoreCredit).to receive(:capture)
            .with(anything, anything, anything, action_originator: originator)
          subject
        end
      end
    end
  end

  context "#void" do
    subject do
      Spree::PaymentMethod::StoreCredit.new.void(auth_code, gateway_options)
    end

    let(:auth_code) { auth_event.authorization_code }
    let(:gateway_options) { super().merge(originator: originator) }
    let(:auth_event) { create(:store_credit_auth_event) }
    let(:originator) { nil }

    context 'with an invalid auth code' do
      let(:auth_code) { 1 }

      it "declines an unknown store credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.unable_to_find')
      end
    end

    context 'when the store credit is not voided successfully' do
      before { allow_any_instance_of(Spree::StoreCredit).to receive_messages(void: false) }

      it "returns an error response" do
        expect(subject.success?).to be false
      end
    end

    it "voids a valid store credit void request" do
      expect(subject.success?).to be true
      expect(subject.message).to include I18n.t('spree.store_credit.successful_action', action: Spree::StoreCredit::VOID_ACTION)
    end

    context 'with an originator' do
      let(:originator) { double('originator') }

      it 'passes the originator' do
        expect_any_instance_of(Spree::StoreCredit).to receive(:void)
          .with(anything, action_originator: originator)
        subject
      end
    end
  end

  context "#purchase" do
    it "declines a purchase if it can't find a pending credit for the correct amount" do
      amount = 100.0
      store_credit = create(:store_credit)
      auth_code = store_credit.generate_authorization_code
      store_credit.store_credit_events.create!(action: Spree::StoreCredit::ELIGIBLE_ACTION,
                                               amount: amount,
                                               authorization_code: auth_code)
      store_credit.store_credit_events.create!(action: Spree::StoreCredit::CAPTURE_ACTION,
                                               amount: amount,
                                               authorization_code: auth_code)

      resp = subject.purchase(amount * 100.0, store_credit, gateway_options)
      expect(resp.success?).to be false
      expect(resp.message).to include I18n.t('spree.store_credit.unable_to_find')
    end

    it "captures a purchase if it can find a pending credit for the correct amount" do
      amount = 100.0
      store_credit = create(:store_credit)
      auth_code = store_credit.generate_authorization_code
      store_credit.store_credit_events.create!(action: Spree::StoreCredit::ELIGIBLE_ACTION,
                                               amount: amount,
                                               authorization_code: auth_code)

      resp = subject.purchase(amount * 100.0, store_credit, gateway_options)
      expect(resp.success?).to be true
      expect(resp.message).to include I18n.t('spree.store_credit.successful_action', action: Spree::StoreCredit::CAPTURE_ACTION)
    end
  end

  context "#credit" do
    subject do
      Spree::PaymentMethod::StoreCredit.new.credit(credit_amount, auth_code, gateway_options)
    end

    let(:credit_amount) { 100.0 }
    let(:auth_code) { auth_event.authorization_code }
    let(:gateway_options) { super().merge(originator: originator) }
    let(:auth_event) { create(:store_credit_auth_event) }
    let(:originator) { nil }

    context 'with an invalid auth code' do
      let(:auth_code) { 1 }

      it "declines an unknown store credit" do
        expect(subject.success?).to be false
        expect(subject.message).to include I18n.t('spree.store_credit.unable_to_find')
      end
    end

    context "when the store credit isn't credited successfully" do
      before { allow_any_instance_of(Spree::StoreCredit).to receive_messages(credit: false) }

      it "returns an error response" do
        expect(subject.success?).to be false
      end
    end

    context 'with a valid credit request' do
      before { allow_any_instance_of(Spree::StoreCredit).to receive_messages(credit: true) }

      it "credits a valid store credit credit request" do
        expect(subject.success?).to be true
        expect(subject.message).to include I18n.t('spree.store_credit.successful_action', action: Spree::StoreCredit::CREDIT_ACTION)
      end
    end

    context 'with an originator' do
      let(:originator) { double('originator') }

      it 'passes the originator' do
        expect_any_instance_of(Spree::StoreCredit).to receive(:credit)
          .with(anything, anything, anything, action_originator: originator)
        subject
      end
    end
  end

  context "#try_void" do
    subject do
      payment_method.try_void(double(response_code: auth_code))
    end

    let(:payment_method)  { described_class.create!(name: 'Store Credit') }
    let(:store_credit)    { create(:store_credit, amount: original_amount, amount_used: captured_amount) }
    let(:auth_code)       { "1-SC-20141111111111" }
    let(:original_amount) { 100.0 }
    let(:captured_amount) { 10.0 }

    shared_examples "a spree payment method" do
      it "returns an ActiveMerchant::Billing::Response" do
        expect(subject).to be_instance_of(ActiveMerchant::Billing::Response)
      end
    end

    context "capture event found" do
      let!(:store_credit_event) do
        create(:store_credit_capture_event,
          authorization_code: auth_code,
          amount: captured_amount,
          store_credit: store_credit)
      end

      it { is_expected.to be(false) }

      describe "called from payment#cancel!" do
        subject { payment.cancel! }

        let!(:payment) do
          create(:payment,
            order: order,
            payment_method: payment_method,
            source: store_credit,
            amount: captured_amount,
            response_code: auth_code)
        end

        it "refunds the capture amount" do
          expect { subject }.to change { store_credit.reload.amount_remaining }.
                                from(original_amount - captured_amount).
                                to(original_amount)
        end
      end
    end

    context "capture event not found" do
      context "auth event found" do
        let!(:store_credit_event) do
          create(:store_credit_auth_event,
            authorization_code: auth_code,
            amount: captured_amount,
            store_credit: store_credit)
        end

        it_behaves_like "a spree payment method"

        it "voids the capture amount" do
          expect { subject }.to change { store_credit.reload.amount_remaining }.
                                from(original_amount - captured_amount).
                                to(original_amount)
        end
      end

      context "store credit event not found" do
        let(:auth_code) { 'INVALID' }

        it_behaves_like "a spree payment method"

        it { is_expected.to_not be_success }
      end
    end
  end
end
