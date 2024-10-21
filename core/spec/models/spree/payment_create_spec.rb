# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe PaymentCreate do
    let(:user) { nil }
    let(:order) { create :order, user: }
    let(:request_env) { {} }
    let(:payment_create) { described_class.new(order, attributes, request_env:) }
    let(:payment_method) { create(:payment_method) }
    let(:new_payment) { payment_create.build }

    context 'empty attributes' do
      let(:attributes){ {} }
      it "builds a new empty payment" do
        expect(new_payment).to be_a Spree::Payment
        expect(new_payment.order).to eq order
        expect(new_payment.source).to be_nil
      end

      it "builds the payment in order.payments" do
        expect(order.payments).to eq [new_payment]
      end
    end

    context 'with a new source' do
      let(:attributes) do
        {
          amount: 100,
          payment_method:,
          source_attributes: {
            expiry: "01 / 99",
            number: '1234567890123',
            verification_value: '123',
            name: 'Foo Bar'
          }
        }
      end

      it "should build the payment's source" do
        expect(new_payment).to be_valid
        expect(new_payment.source).not_to be_nil
        expect(new_payment.source.user_id).to eq order.user_id
        expect(new_payment.source.payment_method_id).to eq payment_method.id
      end

      it "doesn't modify passed-in hash" do
        original = attributes.dup
        new_payment
        expect(original).to eq(attributes)
      end

      context "when payment source not valid" do
        let(:attributes) do
          {
            amount: 100,
            payment_method:,
            source_attributes: { expiry: "1 / 12" }
          }
        end
        it "errors when payment source not valid" do
          expect(new_payment).not_to be_valid
          expect(new_payment).not_to be_persisted
          expect(new_payment.source).not_to be_persisted
          expect(new_payment.source).not_to be_valid
          expect(new_payment.source.errors[:number]).to be_present
          expect(new_payment.source.errors[:verification_value].size).to be_present
        end
      end
    end

    context "with strong params" do
      let(:valid_attributes) do
        {
          amount: 100,
          payment_method:,
          source_attributes: {
            expiry: "01 / 99",
            number: '1234567890123',
            verification_value: '123',
            name: 'Foo Bar'
          }
        }
      end

      context "unpermitted" do
        let(:attributes) { ActionController::Parameters.new(valid_attributes) }

        it "raises an exception" do
          expect {
            new_payment
          }.to raise_exception(ActionController::UnfilteredParameters)
        end
      end

      context "partially permitted" do
        let(:attributes) do
          ActionController::Parameters.new(valid_attributes).permit(:amount)
        end

        it "only uses permitted attributes" do
          expect(new_payment).to have_attributes(
            amount: 100, # permitted
            payment_method: nil, # unpermitted
            source: nil # unpermitted
          )
        end
      end

      context "all permitted" do
        let(:attributes) do
          ActionController::Parameters.new(valid_attributes).permit!
        end

        it "creates a payment with all attributes" do
          expect(new_payment).to have_attributes(
            amount: 100,
            payment_method:,
            source: kind_of(CreditCard)
          )
        end
      end
    end
  end
end
