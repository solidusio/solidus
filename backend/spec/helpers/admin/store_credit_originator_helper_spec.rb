require 'spec_helper'

describe Spree::Admin::StoreCreditOriginatorHelper, type: :helper do
  describe "#store_credit_originator_link" do
    let(:event) { create(:store_credit_adjustment_event, originator: originator) }

    subject { store_credit_originator_link(event) }

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
      let(:originator) { create(:store_credit_update_reason) }

      it "raises an error" do
        expect { subject }.to raise_error(RuntimeError, "Unexpected originator type Spree::StoreCreditUpdateReason")
      end
    end
  end
end
