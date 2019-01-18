# frozen_string_literal: true

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

  describe "#store_credit_event_originator_link" do
    let(:store_credit_event) { create(:store_credit_adjustment_event, originator: originator) }

    subject { store_credit_event_originator_link(store_credit_event) }

    context "originator is a user" do
      let(:originator) { create(:user) }

      it "returns a link to the user's edit page" do
        expect(subject).to eq %(<a target=\"_blank\" href=\"/admin/users/#{originator.id}/edit\">User - #{originator.email}</a>)
      end
    end

    context "originator is a payment" do
      let(:originator) { create(:payment) }

      it "returns a link to the order's payments page" do
        expect(subject).to eq %(<a target=\"_blank\" href=\"/admin/orders/#{originator.order.number}/payments/#{originator.id}\">Payment - Order ##{originator.order.number}</a>)
      end
    end

    context "originator is a refund" do
      let(:originator) { create(:refund, amount: 1.0) }

      it "returns a link to the order's payments page" do
        expect(subject).to eq %(<a target=\"_blank\" href=\"/admin/orders/#{originator.payment.order.number}/payments\">Refund - Order ##{originator.payment.order.number}</a>)
      end
    end

    context "originator is not specifically handled" do
      let(:originator) { create(:store_credit) }

      it "raises an error" do
        expect { subject }.to raise_error(RuntimeError, "Unexpected originator type Spree::StoreCredit")
      end
    end
  end
end
