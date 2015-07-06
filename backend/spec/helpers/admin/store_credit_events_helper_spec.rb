require 'spec_helper'

describe Spree::Admin::StoreCreditEventsHelper, type: :helper do
  describe "#admin_action_name" do
    let(:store_credit_event) { create(:store_credit_event, action: action) }

    subject { admin_action_name(store_credit_event) }

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

  describe "#originator_link" do
    let(:store_credit_event) { create(:store_credit_adjustment_event, originator: originator) }

    subject { originator_link(store_credit_event) }

    context "originator is a user" do
      let(:originator) { create(:user) }

      it "returns a link to the user's edit page" do
        expect(subject).to eq %Q(<a href=\"/admin/users/#{originator.id}/edit\" target=\"_blank\">User - #{originator.email}</a>)
      end
    end

    context "originator is a payment" do
      let(:originator) { create(:payment) }

      it "returns a link to the order's payments page" do
        expect(subject).to eq %Q(<a href=\"/admin/orders/#{originator.order.number}/payments/#{originator.id}\" target=\"_blank\">Payment - Order ##{originator.order.number}</a>)
      end
    end

    context "originator is a refund" do
      let(:originator) { create(:refund, amount: 1.0) }

      it "returns a link to the order's payments page" do
        expect(subject).to eq %Q(<a href=\"/admin/orders/#{originator.payment.order.number}/payments\" target=\"_blank\">Refund - Order ##{originator.payment.order.number}</a>)
      end
    end

    context "originator is a gift card" do
      let(:originator) { create(:virtual_gift_card) }

      it "returns a link to the order's edit page" do
        expect(subject).to eq %Q(<a href=\"/admin/orders/#{originator.line_item.order.number}/edit\" target=\"_blank\">Gift Card - Order ##{originator.line_item.order.number}</a>)
      end
    end

    context "originator is not specifically handled" do
      let(:originator) { create(:store_credit_update_reason) }

      it "raises an error" do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
