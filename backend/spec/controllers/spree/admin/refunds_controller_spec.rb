# frozen_string_literal: true

require "spec_helper"

describe Spree::Admin::RefundsController do
  stub_authorization!

  let(:refund_reason) { create(:refund_reason) }
  let(:refund_amount) { 100.0 }

  let(:payment) { create(:payment, state: "completed", amount: payment_amount) }
  let(:payment_amount) { refund_amount * 2 }

  describe "GET new" do
    subject do
      get(:new, params: {order_id: payment.order_id, payment_id: payment.id})
    end

    it "renders the new template" do
      is_expected.to render_template(:new)
    end

    context "when the payment is not in a refundable state" do
      let(:payment) { create(:payment, state: "checkout", amount: payment_amount) }

      it "redirects to the payments page with an error" do
        subject
        expect(response).to redirect_to(spree.admin_order_payments_path(payment.order))
        expect(flash[:error]).to eq I18n.t("spree.payment_is_not_refundable")
      end
    end

    context "with a customized refundable_payment_states list" do
      before { stub_spree_preferences(refundable_payment_states: %w[completed pending void]) }

      let(:payment) { create(:payment, state: "void", amount: payment_amount) }

      it "renders the new template" do
        is_expected.to render_template(:new)
      end
    end
  end

  describe "POST create" do
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
        expect { subject }.to change(Spree::Refund, :count).by(1)
      end

      it "calls #perform!" do
        subject
        # transaction_id comes from Spree::PaymentMethod::BogusCreditCard.credit
        expect(Spree::Refund.last.transaction_id).to eq("12345")
      end
    end

    context "a Spree::Core::GatewayError is raised" do
      before do
        expect_any_instance_of(Spree::Refund)
          .to receive(:process!)
          .and_raise(Spree::Core::GatewayError.new("An error has occurred"))
      end

      it "does not create a refund record" do
        expect { subject }.to_not change { Spree::Refund.count }
      end

      it "sets an error message with the correct text" do
        subject
        expect(flash[:error]).to eq "An error has occurred"
      end

      it { is_expected.to render_template(:new) }
    end

    context "when the payment is not in a refundable state" do
      %w[checkout invalid].each do |state|
        context "with a #{state} payment" do
          let(:payment) { create(:payment, state:, amount: payment_amount) }

          it "does not create a refund record" do
            expect { subject }.to_not change { Spree::Refund.count }
          end

          it "redirects to the payments page with an error" do
            subject
            expect(response).to redirect_to(spree.admin_order_payments_path(payment.order))
            expect(flash[:error]).to eq I18n.t("spree.payment_is_not_refundable")
          end
        end
      end
    end
  end
end
