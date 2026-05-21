# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe UserRegistrationsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }

  context '#create' do
    before do
      allow(controller).to receive(:after_sign_up_path_for) do
        root_path(thing: 7)
      end
    end

    let(:password_confirmation) { 'foobar123' }

    subject do
      post(
        :create,
        params: {
          spree_user: {
            email: 'foobar@example.com',
            password: 'foobar123',
            password_confirmation: password_confirmation
          }
        }
      )
    end

    context 'when user created successfuly' do
      it 'saves the user' do
        expect { subject }.to change { Spree::User.count }.from(0).to(1)
      end

      it 'sets flash message' do
        subject
        expect(flash[:notice]).to eq('Welcome! You have signed up successfully.')
      end

      it 'signs in user' do
        expect(controller.warden).to receive(:set_user)
        subject
      end

      it 'sets spree_user_signup session' do
        subject
        expect(session[:spree_user_signup]).to be true
      end

      it 'redirects to after_sign_up path' do
        subject
        expect(response).to redirect_to root_path(thing: 7)
      end

      context 'with a guest token present' do
        before do
          request.cookie_jar.signed[:guest_token] = 'ABC'
        end

        it 'assigns orders with the correct token and no user present' do
          order = create(:order, guest_token: 'ABC', user_id: nil, created_by_id: nil)
          subject
          user = Spree::User.find_by(email: 'foobar@example.com')

          order.reload
          expect(order.user_id).to eq user.id
          expect(order.created_by_id).to eq user.id
        end

        it 'does not assign orders with an existing user' do
          order = create(:order, guest_token: 'ABC', user_id: 200)
          subject

          expect(order.reload.user_id).to eq 200
        end

        it 'does not assign orders with a different token' do
          order = create(:order, guest_token: 'DEF', user_id: nil, created_by_id: nil)
          subject

          expect(order.reload.user_id).to be_nil
        end
      end
    end

    context 'when user not valid' do
      let(:password_confirmation) { 'foobard123' }

      it 'resets password fields' do
        expect(controller).to receive(:clean_up_passwords)
        subject
      end

      it 'renders new view' do
        subject
        expect(:response).to render_template(:new)
      end
    end
  end
end
