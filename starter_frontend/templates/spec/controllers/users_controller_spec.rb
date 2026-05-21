# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe UsersController, type: :controller do
  let(:admin_user) { create(:user) }
  let(:user) { create(:user) }
  let(:role) { create(:role) }

  context '#load_object' do
    it 'redirects to signup path if user is not found' do
      put :update, params: { user: { email: 'foobar@example.com' } }
      expect(response).to redirect_to login_path
    end
  end

  context '#create' do
    it 'creates a new user' do
      post :create, params: { user: { email: 'foobar@example.com', password: 'foobar123', password_confirmation: 'foobar123' } }
      expect(assigns[:user].new_record?).to be false
    end
  end

  context '#update' do
    before { sign_in(user) }

    context 'when updating own account' do
      context 'when user updated successfuly' do
        before { put :update, params: { user: { email: 'mynew@email-address.com' } } }

        it 'saves user' do
          expect(assigns[:user].email).to eq 'mynew@email-address.com'
        end

        it 'updates spree_current_user' do
          expect(subject.spree_current_user.email).to eq 'mynew@email-address.com'
        end

        it 'redirects to account url' do
          expect(response).to redirect_to account_url(only_path: true)
        end
      end

      context 'when user not valid' do
        before { put :update, params: { user: { email: '' } } }

        it 'does not affect spree_current_user' do
          expect(subject.spree_current_user.email).to eq user.email
        end
      end

      context 'when updating password' do
        before do
          stub_spree_preferences(Spree::Auth::Config, signout_after_password_change: signout_after_change)
          put :update, params: { user: { password: 'foobar123', password_confirmation: 'foobar123' } }
        end

        context 'when signout after password change is enabled' do
          let(:signout_after_change) { true }

          it 'redirects to login url' do
            expect(response).to redirect_to login_url(only_path: true)
          end
        end

        context 'when signout after password change is disabled' do
          let(:signout_after_change) { false }

          it 'redirects to account url' do
            expect(response).to redirect_to account_url(only_path: true)
          end
        end
      end
    end

    it 'does not update roles' do
      put :update, params: { user: { spree_role_ids: [role.id] } }
      expect(assigns[:user].spree_roles).to_not include role
    end
  end
end
