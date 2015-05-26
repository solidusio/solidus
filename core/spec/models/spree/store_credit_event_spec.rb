require 'spec_helper'

describe Spree::StoreCreditEvent do

  describe ".exposed_events" do

    [
      Spree::StoreCredit::ELIGIBLE_ACTION,
      Spree::StoreCredit::AUTHORIZE_ACTION,
    ].each do |action|
      let(:action) { action }
      it "excludes #{action} actions" do
        event = create(:store_credit_event, action: action)
        expect(described_class.exposed_events).not_to include event
      end
    end

    [
      Spree::StoreCredit::VOID_ACTION,
      Spree::StoreCredit::CREDIT_ACTION,
      Spree::StoreCredit::CAPTURE_ACTION,
      Spree::StoreCredit::ALLOCATION_ACTION,
    ].each do |action|
      it "includes #{action} actions" do
        event = create(:store_credit_event, action: action)
        expect(described_class.exposed_events).to include event
      end
    end

    it "excludes invalidated store credit events" do
      invalidated_store_credit = create(:store_credit, invalidated_at: Time.now)
      event = create(:store_credit_event, action: Spree::StoreCredit::VOID_ACTION, store_credit: invalidated_store_credit)
      expect(described_class.exposed_events).not_to include event
    end
  end

  describe "#capture_action?" do
    subject { event.capture_action? }

    context "for capture events" do
      let(:event) { create(:store_credit_capture_event) }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "for non-capture events" do
      let(:event) { create(:store_credit_auth_event) }

      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#authorization_action?" do
    subject { event.authorization_action? }

    context "for auth events" do
      let(:event) { create(:store_credit_auth_event) }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "for non-auth events" do
      let(:event) { create(:store_credit_capture_event) }

      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#display_amount" do
    let(:event_amount) { 120.0 }

    subject { create(:store_credit_auth_event, amount: event_amount) }

    it "returns a Spree::Money instance" do
      expect(subject.display_amount).to be_instance_of(Spree::Money)
    end

    it "uses the events amount attribute" do
      expect(subject.display_amount).to eq Spree::Money.new(event_amount, { currency: subject.currency })
    end
  end

  describe "#display_user_total_amount" do
    let(:user_total_amount) { 300.0 }

    subject { create(:store_credit_auth_event, user_total_amount: user_total_amount) }

    it "returns a Spree::Money instance" do
      expect(subject.display_user_total_amount).to be_instance_of(Spree::Money)
    end

    it "uses the events user_total_amount attribute" do
      expect(subject.display_user_total_amount).to eq Spree::Money.new(user_total_amount, { currency: subject.currency })
    end
  end

  describe "#display_event_date" do
    let(:date) { DateTime.new(2014, 06, 1) }

    subject { create(:store_credit_auth_event, created_at: date) }

    it "returns the date the event was created with the format month/date/year" do
      expect(subject.display_event_date).to eq "June 01, 2014"
    end
  end

  describe "#display_action" do
    subject { create(:store_credit_auth_event, action: action) }

    context "capture event" do
      let(:action) { Spree::StoreCredit::CAPTURE_ACTION }

      it "returns used" do
        expect(subject.display_action).to eq Spree.t('store_credit.captured')
      end
    end

    context "authorize event" do
      let(:action) { Spree::StoreCredit::AUTHORIZE_ACTION }

      it "returns authorized" do
        expect(subject.display_action).to eq Spree.t('store_credit.authorized')
      end
    end

    context "allocation event" do
      let(:action) { Spree::StoreCredit::ALLOCATION_ACTION }

      it "returns added" do
        expect(subject.display_action).to eq Spree.t('store_credit.allocated')
      end
    end

    context "void event" do
      let(:action) { Spree::StoreCredit::VOID_ACTION }

      it "returns credit" do
        expect(subject.display_action).to eq Spree.t('store_credit.credit')
      end
    end

    context "credit event" do
      let(:action) { Spree::StoreCredit::CREDIT_ACTION }

      it "returns credit" do
        expect(subject.display_action).to eq Spree.t('store_credit.credit')
      end
    end
  end

  describe "#order" do
    context "there is no associated payment with the event" do
      subject { create(:store_credit_auth_event) }

      it "returns nil" do
        expect(subject.order).to be_nil
      end
    end

    context "there is an associated payment with the event" do
      let(:authorization_code) { "1-SC-TEST" }
      let(:order)              { create(:order) }
      let!(:payment)           { create(:store_credit_payment, order: order, response_code: authorization_code) }

      subject { create(:store_credit_auth_event, action: Spree::StoreCredit::CAPTURE_ACTION, authorization_code: authorization_code) }

      it "returns the order associated with the payment" do
        expect(subject.order).to eq order
      end
    end
  end
end
