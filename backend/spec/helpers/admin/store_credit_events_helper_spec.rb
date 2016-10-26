require 'spec_helper'

describe Spree::Admin::StoreCreditEventsHelper, type: :helper do
  describe "#store_credit_event_admin_action_name" do
    let(:store_credit_event) { create(:store_credit_event, action: action) }

    subject { store_credit_event_admin_action_name(store_credit_event) }

    context "capture event" do
      let(:action) { Spree::StoreCredit::CAPTURE_ACTION }

      it "returns the action's display text" do
        expect(subject).to eq "Used"
      end
    end

    context "authorize event" do
      let(:action) { Spree::StoreCredit::AUTHORIZE_ACTION }

      it "returns the action's display text" do
        expect(subject).to eq "Authorized"
      end
    end

    context "eligible event" do
      let(:action) { Spree::StoreCredit::ELIGIBLE_ACTION }

      it "returns the action's display text" do
        expect(subject).to eq "Eligibility Verified"
      end
    end

    context "allocation event" do
      let(:action) { Spree::StoreCredit::ALLOCATION_ACTION }

      it "returns the action's display text" do
        expect(subject).to eq "Added"
      end
    end

    context "void event" do
      let(:action) { Spree::StoreCredit::VOID_ACTION }

      it "returns the action's display text" do
        expect(subject).to eq "Voided"
      end
    end

    context "credit event" do
      let(:action) { Spree::StoreCredit::CREDIT_ACTION }

      it "returns the action's display text" do
        expect(subject).to eq "Credit"
      end
    end
  end
end
