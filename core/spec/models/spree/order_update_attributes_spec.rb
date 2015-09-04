require 'spec_helper'

module Spree
  RSpec.describe OrderUpdateAttributes do
    let(:order) { create(:order) }
    let(:request_env) { nil }
    let(:update) { described_class.new(order, attributes, request_env: request_env) }

    context 'empty attributes' do
      let(:attributes){ {} }
      it 'succeeds' do
        expect(update.update).to be_truthy
      end
    end

    context 'with coupon code' do
      let(:attributes){ {coupon_code: 'abc123'} }
      it "sets coupon code" do
        expect(update.update).to be_truthy
        expect(order.coupon_code).to eq('abc123')
      end
    end

    context 'with payment attributes' do
      let(:attributes) do
        {
          payments_attributes: [
            {source_attributes: attributes_for(:credit_card)}
          ]
        }
      end

      context 'with params and a request_env' do
        let(:request_env){ {'USER_AGENT' => 'Firefox'} }
        it 'sets the request_env on the payment' do
          expect(update.update).to be_truthy
          expect(order.payments.length).to eq 1
          expect(order.payments[0].request_env).to eq({'USER_AGENT' => 'Firefox'})
        end
      end
    end
  end
end
