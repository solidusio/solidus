# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::UsersController, type: :request do
    let(:user) { create(:user, spree_api_key: SecureRandom.hex) }
    let(:stranger) { create(:user, email: 'stranger@example.com') }
    let(:attributes) { [:id, :email, :created_at, :updated_at] }

    context "as a normal user" do
      it "can get own details" do
        get spree.api_user_path(user.id), params: { token: user.spree_api_key }

        expect(json_response['email']).to eq user.email
      end

      it "cannot get other users details" do
        get spree.api_user_path(stranger.id), params: { token: user.spree_api_key }

        assert_not_found!
      end

      it "can learn how to create a new user" do
        get spree.new_api_user_path, params: { token: user.spree_api_key }
        expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
      end

      it "can create a new user" do
        user_params = {
          email: 'new@example.com', password: 'spree123', password_confirmation: 'spree123'
        }

        post spree.api_users_path, params: { user: user_params, token: user.spree_api_key }
        expect(json_response['email']).to eq 'new@example.com'
      end

      # there's no validations on LegacyUser?
      xit "cannot create a new user with invalid attributes" do
        post spree.api_users_path, params: { user: {}, token: user.spree_api_key }
        expect(response.status).to eq(422)
        expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
      end

      it "can update own details" do
        country = create(:country)
        put spree.api_user_path(user.id), params: { token: user.spree_api_key, user: {
          email: "mine@example.com",
          bill_address_attributes: {
            name: 'First Last',
            address1: '1 Test Rd',
            city: 'City',
            country_id: country.id,
            state_id: 1,
            zipcode: '55555',
            phone: '5555555555'
          },
          ship_address_attributes: {
            name: 'First Last',
            address1: '1 Test Rd',
            city: 'City',
            country_id: country.id,
            state_id: 1,
            zipcode: '55555',
            phone: '5555555555'
          }
        } }
        expect(json_response['email']).to eq 'mine@example.com'
        expect(json_response['bill_address']).to_not be_nil
        expect(json_response['ship_address']).to_not be_nil
      end

      it "cannot update other users details" do
        put spree.api_user_path(stranger.id), params: { token: user.spree_api_key, user: { email: "mine@example.com" } }
        assert_not_found!
      end

      it "cannot delete itself" do
        delete spree.api_user_path(user.id), params: { token: user.spree_api_key }
        expect(response.status).to eq(401)
      end

      it "cannot delete other user" do
        delete spree.api_user_path(stranger.id), params: { token: user.spree_api_key }
        assert_not_found!
      end

      it "should only get own details on index" do
        2.times { create(:user) }
        get spree.api_users_path, params: { token: user.spree_api_key }

        expect(Spree.user_class.count).to eq 3
        expect(json_response['count']).to eq 1
        expect(json_response['users'].size).to eq 1
      end
    end

    context "as an admin" do
      before { stub_authentication! }

      sign_in_as_admin!

      it "gets all users" do
        allow(Spree::LegacyUser).to receive(:find_by).with(hash_including(:spree_api_key)) { current_api_user }

        2.times { create(:user) }

        get spree.api_users_path
        expect(Spree.user_class.count).to eq 2
        expect(json_response['count']).to eq 2
        expect(json_response['users'].size).to eq 2
      end

      it 'can control the page size through a parameter' do
        2.times { create(:user) }
        get spree.api_users_path, params: { per_page: 1 }
        expect(json_response['count']).to eq(1)
        expect(json_response['current_page']).to eq(1)
        expect(json_response['pages']).to eq(2)
      end

      it 'can query the results through a paramter' do
        expected_result = create(:user, email: 'brian@spreecommerce.com')
        get spree.api_users_path, params: { q: { email_cont: 'brian' } }
        expect(json_response['count']).to eq(1)
        expect(json_response['users'].first['email']).to eq expected_result.email
      end

      it "can create" do
        post spree.api_users_path, params: { user: { email: "new@example.com", password: 'spree123', password_confirmation: 'spree123' } }
        expect(json_response).to have_attributes(attributes)
        expect(response.status).to eq(201)
      end

      it "can destroy user without orders" do
        user.orders.destroy_all
        delete spree.api_user_path(user)
        expect(response.status).to eq(204)
      end

      it "cannot destroy user with orders" do
        create(:completed_order_with_totals, user: user)
        delete spree.api_user_path(user)
        expect(response.status).to eq(422)
        expect(json_response).to eq({ "error" => "Cannot delete record." })
      end
    end
  end
end
