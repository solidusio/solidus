# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe OrdersController, type: :controller do
    ORDER_TOKEN = 'ORDER_TOKEN'

    let!(:store) { create(:store) }
    let(:order) { Spree::Order.create }
    let(:variant) { create(:variant) }

    it 'should understand order routes with token' do
      expect(spree.token_order_path('R123456', 'ABCDEF')).to eq('/orders/R123456/token/ABCDEF')
    end

    context 'when an order exists in the cookies.signed' do
      let(:token) { 'some_token' }

      before do
        allow(controller).to receive_messages current_order: order
      end

      context '#populate' do
        it 'should check if user is authorized for :update' do
          expect(controller).to receive(:authorize!).with(:update, order, token)
          post :populate, params: { variant_id: variant.id, token: token }
        end
      end

      context '#edit' do
        it 'should check if user is authorized for :read' do
          expect(controller).to receive(:authorize!).with(:read, order, token)
          get :edit, params: { token: token }
        end
      end

      context '#update' do
        it 'should check if user is authorized for :update' do
          allow(order).to receive :update
          expect(controller).to receive(:authorize!).with(:update, order, token)
          post :update, params: { order: { email: "foo@bar.com" }, token: token }
        end
      end

      context '#empty' do
        it 'should check if user is authorized for :update' do
          expect(controller).to receive(:authorize!).with(:update, order, token)
          post :empty, params: { token: token }
        end
      end

      context "#show" do
        let(:specified_order) { create(:order) }

        it "should check against the specified order" do
          expect(controller).to receive(:authorize!).with(:read, specified_order, token)
          get :show, params: { id: specified_order.number, token: token }
        end
      end
    end

    context 'when no authenticated user' do
      let(:order) { create(:order, number: 'R123') }

      context '#show' do
        context 'when token parameter present' do
          it 'always ooverride existing token when passing a new one' do
            cookies.signed[:guest_token] = "soo wrong"
            get :show, params: { id: 'R123', token: order.guest_token }
            expect(cookies.signed[:guest_token]).to eq(order.guest_token)
          end

          it 'should store as guest_token in session' do
            get :show, params: { id: 'R123', token: order.guest_token }
            expect(cookies.signed[:guest_token]).to eq(order.guest_token)
          end
        end

        context 'when no token present' do
          it 'should respond with 404' do
            expect {
              get :show, params: { id: 'R123' }
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
