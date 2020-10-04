# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::StoreCreditEvent do
  describe ".exposed_events" do
    [
      Spree::StoreCredit::ELIGIBLE_ACTION,
      Spree::StoreCredit::AUTHORIZE_ACTION
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
      Spree::StoreCredit::ALLOCATION_ACTION
    ].each do |action|
      it "includes #{action} actions" do
        event = create(:store_credit_event, action: action)
        expect(described_class.exposed_events).to include event
      end
    end

    it "excludes invalidated store credit events" do
      invalidated_store_credit = create(:store_credit, invalidated_at: Time.current)
      event = create(:store_credit_event, action: Spree::StoreCredit::VOID_ACTION, store_credit: invalidated_store_credit)
      expect(described_class.exposed_events).not_to include event
    end
  end

  describe "update store credit reason validation" do
    subject { event.valid? }

    context "adjustment event" do
      context "has a store credit reason" do
        let(:event) { build(:store_credit_adjustment_event) }

        it "returns true" do
          expect(subject).to eq true
        end
      end

      context "doesn't have a store credit reason" do
        let(:event) { build(:store_credit_adjustment_event, store_credit_reason: nil) }

        it "returns false" do
          expect(subject).to eq false
        end

        it "adds an error message indicating the store credit reason is missing" do
          subject
          expect(event.errors.full_messages).to match ["Store credit reason can't be blank"]
        end
      end
    end

    context "invalidate event" do
      context "has a store credit reason" do
        let(:event) { build(:store_credit_invalidate_event) }

        it "returns true" do
          expect(subject).to eq true
        end
      end

      context "doesn't have a store credit reason" do
        let(:event) { build(:store_credit_invalidate_event, store_credit_reason: nil) }

        it "returns false" do
          expect(subject).to eq false
        end

        it "adds an error message indicating the store credit reason is missing" do
          subject
          expect(event.errors.full_messages).to match ["Store credit reason can't be blank"]
        end
      end
    end

    context "event doesn't require a store credit reason" do
      let(:event) { build(:store_credit_auth_event) }

      it "returns true" do
        expect(subject).to eq true
      end
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

  describe "#action_requires_reason?" do
    subject { event.action_requires_reason? }

    context "for adjustment events" do
      let(:event) { create(:store_credit_adjustment_event) }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "for invalidate events" do
      let(:event) { create(:store_credit_invalidate_event) }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "for capture events" do
      let(:event) { create(:store_credit_capture_event) }

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "for authorize events" do
      let(:event) { create(:store_credit_auth_event) }

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "for allocation events" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::ALLOCATION_ACTION) }

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "for void events" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::VOID_ACTION) }

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "for credit events" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::CREDIT_ACTION) }

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

  describe "#display_remaining_amount" do
    let(:amount_remaining) { 300.0 }

    subject { create(:store_credit_auth_event, amount_remaining: amount_remaining) }

    it "returns a Spree::Money instance" do
      expect(subject.display_remaining_amount).to be_instance_of(Spree::Money)
    end

    it "uses the events amount_remaining attribute" do
      expect(subject.display_remaining_amount).to eq Spree::Money.new(amount_remaining, { currency: subject.currency })
    end
  end

  describe "#display_event_date" do
    let(:date) { Time.zone.parse("2014-06-01") }

    subject { create(:store_credit_auth_event, created_at: date) }

    it "returns the date the event was created with the format month/date/year" do
      expect(subject.display_event_date).to eq "June 01, 2014"
    end
  end

  describe "#display_action" do
    subject { event.display_action }

    context "capture event" do
      let(:event) { create(:store_credit_capture_event) }

      it "returns the action's display text" do
        expect(subject).to eq "Used"
      end
    end

    context "allocation event" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::ALLOCATION_ACTION) }

      it "returns the action's display text" do
        expect(subject).to eq "Added"
      end
    end

    context "void event" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::VOID_ACTION) }

      it "returns the action's display text" do
        expect(subject).to eq "Credit"
      end
    end

    context "credit event" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::CREDIT_ACTION) }

      it "returns the action's display text" do
        expect(subject).to eq "Credit"
      end
    end

    context "adjustment event" do
      let(:event) { create(:store_credit_adjustment_event) }

      it "returns the action's display text" do
        expect(subject).to eq "Adjustment"
      end
    end

    context "authorize event" do
      let(:event) { create(:store_credit_auth_event) }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "eligible event" do
      let(:event) { create(:store_credit_event, action: Spree::StoreCredit::ELIGIBLE_ACTION) }

      it "returns nil" do
        expect(subject).to be_nil
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
