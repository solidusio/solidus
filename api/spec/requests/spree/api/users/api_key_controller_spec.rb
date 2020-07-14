# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::Users::ApiKeyController, type: :request do
    let(:user) { create(:user) }
    let(:admin) { create(:admin_user) }

    before do
      stub_authentication!
    end

    context 'with ability to manage user' do
      stub_authorization! do
        can [:manage], user
      end

      describe '#create' do
        it 'return api_key' do
          expect(user.spree_api_key).to be(nil)
          post "/api/users/#{user.id}/api_key"
          expect(response.status).to eq(200)
          api_key = json_response['spree_api_key']
          expect(api_key).not_to be(nil)
          user.reload
          expect(user.spree_api_key).to eq(api_key)
        end
      end

      describe '#delete' do
        it 'clean user api_key' do
          user.generate_spree_api_key!
          expect(user.spree_api_key).not_to be(nil)
          delete "/api/users/#{user.id}/api_key"
          expect(response.status).to eq(204)
          user.reload
          expect(user.spree_api_key).to be(nil)
        end
      end
    end

    context 'without ability to manage user' do
      describe '#create' do
        it 'return 401' do
          expect(user.spree_api_key).to be(nil)
          post "/api/users/#{user.id}/api_key"
          assert_unauthorized!
          user.reload
          expect(user.spree_api_key).to be(nil)
        end
      end

      describe '#delete' do
        it 'return 401' do
          user.generate_spree_api_key!
          expect(user.spree_api_key).not_to be(nil)
          delete "/api/users/#{user.id}/api_key"
          assert_unauthorized!
          user.reload
          expect(user.spree_api_key).not_to be(nil)
        end
      end
    end
  end
end
