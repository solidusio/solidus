# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ControllerHelpers::PaymentParameters, type: :controller do
  controller(ApplicationController) do
    include Spree::Core::ControllerHelpers::PaymentParameters
  end

  let(:params_hash) { subject.permit!.to_h.deep_symbolize_keys }

  shared_examples "unpermitted params" do
    it "is unpermitted ActionController::Parameters" do
      expect(subject).to be_a(ActionController::Parameters)
      expect(subject).not_to be_permitted
    end
  end

  shared_examples "unchanged params" do
    let!(:original_param_hash) { params.dup.permit!.to_h.deep_symbolize_keys }

    it 'returns the original hash' do
      expect(params_hash).to eq(original_param_hash)
    end

    it_behaves_like "unpermitted params"
  end

  describe '#move_payment_source_into_payments_attributes' do
    subject do
      controller.move_payment_source_into_payments_attributes(params)
    end

    let(:params) do
      ActionController::Parameters.new(
        payment_source: {
          payment_method_1.id.to_s => credit_card_1_params,
          payment_method_2.id.to_s => credit_card_2_params
        },
        order: {
          payments_attributes: [
            {
              payment_method_id: payment_method_1.id.to_s
            }
          ],
          other_order_param: 1
        },
        other_param: 2
      )
    end

    let(:payment_method_1) { create(:credit_card_payment_method) }
    let(:payment_method_2) { create(:credit_card_payment_method) }
    let(:credit_card_1_params) { attributes_for(:credit_card, name: 'Jordan1') }
    let(:credit_card_2_params) { attributes_for(:credit_card, name: 'Jordan2') }

    it 'produces the expected hash' do
      expect(params_hash).to eq(
        order: {
          payments_attributes: [
            {
              payment_method_id: payment_method_1.id.to_s,
              source_attributes: credit_card_1_params
            }
          ],
          other_order_param: 1
        },
        other_param: 2
      )
    end

    it_behaves_like "unpermitted params"

    context 'when payment_source is missing' do
      before { params.delete(:payment_source) }
      it_behaves_like "unchanged params"
    end

    context 'when order params are missing' do
      before { params.delete(:order) }
      it_behaves_like "unchanged params"
    end

    context 'when payment_attributes are missing' do
      before { params[:order].delete(:payments_attributes) }
      it_behaves_like "unchanged params"
    end

    context 'when the payment_method_id is missing' do
      before { params[:order][:payments_attributes][0].delete(:payment_method_id) }
      it_behaves_like "unchanged params"
    end

    context 'when the payment_method_id does not match a payments source' do
      before { params[:order][:payments_attributes][0][:payment_method_id] = -1 }
      it_behaves_like "unchanged params"
    end
  end

  describe '#move_existing_card_into_payments_attributes' do
    subject do
      controller.move_existing_card_into_payments_attributes(params)
    end

    let(:params) do
      ActionController::Parameters.new(
        order: {
          existing_card: '123',
          other_order_param: 1
        },
        cvc_confirm: '456',
        other_param: 2
      )
    end

    it 'produces the expected hash' do
      expect(params_hash).to eq(
        order: {
          payments_attributes: [
            {
              source_attributes: {
                existing_card_id: '123',
                verification_value: '456'
              }
            }
          ],
          other_order_param: 1
        },
        other_param: 2
      )
    end

    it_behaves_like "unpermitted params"

    context 'when cvc_confirm is missing' do
      before { params.delete(:cvc_confirm) }

      it 'produces the expected hash' do
        expect(params_hash).to eq(
          order: {
            payments_attributes: [
              {
                source_attributes: {
                  existing_card_id: '123',
                  verification_value: nil
                }
              }
            ],
            other_order_param: 1
          },
          other_param: 2
        )
      end

      it_behaves_like "unpermitted params"
    end

    context 'when order params are missing' do
      before { params.delete(:order) }
      it_behaves_like "unchanged params"
    end

    context 'when existing_card is missing' do
      before { params[:order].delete(:existing_card) }
      it_behaves_like "unchanged params"
    end
  end

  describe '#set_payment_parameters_amount' do
    subject do
      controller.set_payment_parameters_amount(params, order)
    end

    let(:params) do
      ActionController::Parameters.new(
        order: {
          payments_attributes: [{}],
          other_order_param: 1
        },
        other_param: 2
      )
    end
    let(:order) { create(:order_with_line_items, line_items_price: 101.00, line_items_count: 1, shipment_cost: 0) }

    it 'produces the expected hash' do
      expect(params_hash).to eq(
        order: {
          payments_attributes: [{ amount: 101 }],
          other_order_param: 1
        },
        other_param: 2
      )
    end
  end
end
