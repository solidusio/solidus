# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::RefundsController do
  stub_authorization!

  describe "POST create" do
    let(:refund_reason) { create(:refund_reason) }
    let(:refund_amount) { 100.0 }

    let(:payment) { create(:payment, amount: payment_amount) }
    let(:payment_amount) { refund_amount * 2 }

    subject do
      post(
        :create,
        params: {
          refund: {
            amount: refund_amount,
            refund_reason_id: refund_reason.id,
            transaction_id: nil
          },
          order_id: payment.order_id,
          payment_id: payment.id
        }
      )
    end

    context "and no Spree::Core::GatewayError is raised" do
      it "creates a refund record" do
        expect{ subject }.to change(Spree::Refund, :count).by(1)
      end

      it "calls #perform!" do
        subject
        # transaction_id comes from Spree::Gateway::Bogus.credit
        expect(Spree::Refund.last.transaction_id).to eq("12345")
      end
    end

    context "a Spree::Core::GatewayError is raised" do
      before do
        expect_any_instance_of(Spree::Refund).
          to receive(:perform!).
          and_raise(Spree::Core::GatewayError.new('An error has occurred'))
      end

      it "does not create a refund record" do
        expect{ subject }.to_not change { Spree::Refund.count }
      end

      it "sets an error message with the correct text" do
        subject
        expect(flash[:error]).to eq 'An error has occurred'
      end

      it { is_expected.to render_template(:new) }
    end
  end
end
