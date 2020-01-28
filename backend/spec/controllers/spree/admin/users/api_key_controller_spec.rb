# frozen_string_literal: true

require "spec_helper"

describe Spree::Admin::Users::ApiKeyController, type: :controller do
  let(:user) { create(:user) }

  describe '#create' do
    context "with ability to manage users and API keys" do
      stub_authorization! do |_user|
        can [:manage], Spree.user_class
        can [:manage], :api_key
      end

      it "allows admins to create a new user's API key" do
        post :create, params: { user_id: user.id }

        expect(flash[:success]).to eq I18n.t('spree.admin.api.key_generated')
        expect(response).to redirect_to(spree.edit_admin_user_path(user))
      end
    end

    context "without ability to manage users and API keys" do
      stub_authorization! do |_user|
      end

      it 'denies access' do
        delete :destroy, params: { user_id: user.id }

        expect(flash[:error]).to eq I18n.t('spree.authorization_failure')
        expect(response).to redirect_to '/unauthorized'
      end
    end
  end

  describe '#destroy' do
    context "with ability to manage users and API keys" do
      stub_authorization! do |_user|
        can [:manage], Spree.user_class
        can [:manage], :api_key
      end

      it "allows admins to clear an existing user's API key" do
        user.generate_spree_api_key!
        delete :destroy, params: { user_id: user.id }

        expect(flash[:success]).to eq I18n.t('spree.admin.api.key_cleared')
        expect(response).to redirect_to(spree.edit_admin_user_path(user))
      end
    end

    context "without ability to manage users and API keys" do
      stub_authorization! do |_user|
      end

      it 'denies access' do
        delete :destroy, params: { user_id: user.id }

        expect(flash[:error]).to eq I18n.t('spree.authorization_failure')
        expect(response).to redirect_to '/unauthorized'
      end
    end
  end
end
