# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe UserPasswordsController, type: :controller do
  let(:token) { 'some_token' }

  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }

  describe 'GET edit' do
    context 'when the user token has not been specified' do
      it 'redirects to the new session path' do
        get :edit
        expect(response).to redirect_to(
          'http://test.host/user/sign_in'
        )
      end

      it 'flashes an error' do
        get :edit
        expect(flash[:alert]).to include(
          "You can't access this page without coming from a password reset " \
          'email'
        )
      end
    end

    context 'when the user token has been specified' do
      it 'does something' do
        get :edit, params: { reset_password_token: token }
        expect(response.code).to eq('200')
      end
    end
  end

  context '#update' do
    context 'when updating password with blank password' do
      it 'shows error flash message, sets spree_user with token and re-displays password edit form' do
        put :update, params: { spree_user: { password: '', password_confirmation: '', reset_password_token: token } }
        expect(assigns(:spree_user).is_a?(Spree::User)).to eq true
        expect(assigns(:spree_user).reset_password_token).to eq token
        expect(flash[:error]).to eq I18n.t(:cannot_be_blank, scope: [:devise, :user_passwords, :spree_user])
        expect(response).to render_template :edit
      end
    end
  end
end
