# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe CheckoutsController, type: :controller do
  let(:order) { create(:order_with_line_items, email: nil, user: nil, guest_token: token) }
  let(:user)  { build(:user, spree_api_key: 'fake') }
  let(:token) { 'some_token' }
  let(:cookie_token) { token }

  before do
    request.cookie_jar.signed[:guest_token] = cookie_token
    allow(controller).to receive(:current_order) { order }
  end

  context '#edit' do
    context 'when registration step enabled' do
      context 'when authenticated as registered user' do
        before { allow(controller).to receive(:spree_current_user) { user } }

        it 'proceeds to the first checkout step' do
          get :edit, params: { state: 'address' }
          expect(response).to render_template :edit
        end
      end

      context 'when not authenticated as guest' do
        it 'redirects to registration step' do
          get :edit, params: { state: 'address' }
          expect(response).to redirect_to new_checkout_session_path
        end
      end

      context 'when authenticated as guest' do
        before { order.email = 'guest@solidus.io' }

        it 'proceeds to the first checkout step' do
          get :edit, params: { state: 'address' }
          expect(response).to render_template :edit
        end

        context 'when guest checkout not allowed' do
          before do
            stub_spree_preferences(allow_guest_checkout: false)
          end

          it 'redirects to registration step' do
            get :edit, params: { state: 'address' }
            expect(response).to redirect_to new_checkout_session_path
          end
        end
      end
    end

    context 'when registration step disabled' do
      before do
        stub_spree_preferences(Spree::Auth::Config, registration_step: false)
      end

      context 'when authenticated as registered' do
        before { allow(controller).to receive(:spree_current_user) { user } }

        it 'proceeds to the first checkout step' do
          get :edit, params: { state: 'address' }
          expect(response).to render_template :edit
        end
      end

      context 'when authenticated as guest' do
        it 'proceeds to the first checkout step' do
          get :edit, params: { state: 'address' }
          expect(response).to render_template :edit
        end
      end
    end
  end

  context '#update' do
    context 'when in the confirm state' do
      before do
        order.update(email: 'spree@example.com', state: 'confirm')

        # So that the order can transition to complete successfully
        allow(order).to receive(:payment_required?) { false }
      end

      context 'with a token' do
        before { allow(order).to receive(:guest_token) { 'ABC' } }

        it 'redirects to the tokenized order view' do
          request.cookie_jar.signed[:guest_token] = 'ABC'
          post :update, params: { state: 'confirm' }
          expect(response).to redirect_to token_order_path(order, 'ABC')
          expect(flash.notice).to eq I18n.t('spree.order_processed_successfully')
        end
      end

      context 'with a registered user' do
        before do
          allow(controller).to receive(:spree_current_user) { user }
          allow(order).to receive(:user) { user }
          allow(order).to receive(:guest_token) { nil }
        end

        it 'redirects to the standard order view' do
          post :update, params: { state: 'confirm' }
          expect(response).to redirect_to order_path(order)
        end
      end
    end
  end
end
