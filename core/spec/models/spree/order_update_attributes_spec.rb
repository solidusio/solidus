# frozen_string_literal: true

require "rails_helper"

module Spree
  RSpec.describe OrderUpdateAttributes do
    let(:order) { create(:order) }
    let(:payment_method) { create(:payment_method) }
    let(:request_env) { nil }
    let(:update) { described_class.new(order, attributes, request_env:) }

    context "empty attributes" do
      let(:attributes) { {} }
      it "succeeds" do
        expect(update.call).to be_truthy
      end
    end

    context "with coupon code" do
      let(:attributes) { {coupon_code: "abc123"} }
      it "sets coupon code" do
        expect(update.call).to be_truthy
        expect(order.coupon_code).to eq("abc123")
      end
    end

    context "with payment attributes" do
      let(:attributes) do
        {
          payments_attributes: [
            {
              payment_method_id: payment_method.id,
              source_attributes: attributes_for(:credit_card)
            }
          ]
        }
      end

      context "with params and a request_env" do
        let(:request_env) { {"USER_AGENT" => "Firefox"} }
        it "sets the request_env on the payment" do
          expect(update.call).to be_truthy
          expect(order.payments.length).to eq 1
          expect(order.payments[0].request_env).to eq({"USER_AGENT" => "Firefox"})
        end
      end
    end

    context "with payment attributes for an existing payment" do
      let(:payment) { create(:payment, order:, payment_method:, amount: 10) }
      let(:original_source) { payment.source }

      let(:attributes) do
        {
          payments_attributes: [
            {
              id: payment.id,
              payment_method_id: payment_method.id,
              amount: 20,
              source_attributes: attributes_for(:credit_card, number: "5555555555554444")
            }
          ]
        }
      end

      it "does not create a new payment" do
        payment # ensure the payment is created before the update

        expect { update.call }.not_to change { order.payments.reload.count }
      end

      it "replaces the source on the existing payment" do
        expect {
          update.call
        }.to change { payment.reload.source }.from(original_source)

        expect(payment.reload.source.last_digits).to eq("4444")
      end

      it "updates the amount on the existing payment" do
        expect {
          update.call
        }.to change { payment.reload.amount }.from(10).to(20)
      end

      context "when the payment is not in the checkout state" do
        let(:payment) { create(:payment, order:, payment_method:, state: "completed") }

        it "raises RecordNotFound" do
          expect { update.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
