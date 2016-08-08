require 'spec_helper'

module Spree
  describe Api::CreditCardsController, type: :controller do
    let(:creditcard_base_attributes) { Api::ApiHelpers.creditcard_attributes }
    describe '#index' do
      render_views

      let!(:admin_user) do
        create(:admin_user)
      end

      let!(:normal_user) do
        create(:user, :with_api_key)
      end

      let!(:second_normal_user) do
        create(:user, :with_api_key)
      end

      let!(:third_normal_user) do
        create(:user, :with_api_key)
      end

      let!(:card) { create(:credit_card, user_id: admin_user.id, gateway_customer_profile_id: "random") }

      let!(:card_for_successful_delete_attempt) { create(:credit_card, user_id: second_normal_user.id, gateway_customer_profile_id: "randomsecond") }
      let!(:card_for_unsuccessful_delete_attempt) { create(:credit_card, user_id: third_normal_user.id, gateway_customer_profile_id: "randomthird") }

      before do
        stub_authentication!
      end

      it "the user id doesn't exist" do
        api_get :index, user_id: 1000
        expect(response.status).to eq(404)
      end

      context "calling user is in admin role" do
        let(:current_api_user) do
          admin_user
        end

        it "no credit cards exist for user" do
          api_get :index, user_id: normal_user.id

          expect(response.status).to eq(200)
          expect(json_response["pages"]).to eq(0)
        end

        it "can view all credit cards for user" do
          api_get :index, user_id: current_api_user.id

          expect(response.status).to eq(200)
          expect(json_response["pages"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["credit_cards"].length).to eq(1)
          expect(json_response["credit_cards"].first["id"]).to eq(card.id)
        end

        it "can create credit cards for other users" do
          api_post :create, user_id: normal_user.id, credit_card: {
            name: "Art Vanderlay",
            cc_type: "discover",
            last_digits: "7890",
            month: 3,
            year: 2086,
            payment_method_id: 1,
            gateway_customer_profile_id: "12345678",
            gateway_payment_profile_id: "abc123",
            address_attributes: {
              firstname: "Art",
              lastname: "Vanderlay",
              address1: "1344 Queens Boulevard",
              address2: "",
              city: "Queens",
              state_name: "New York",
              zipcode: "11375",
              country_iso: "US",
              phone: "867-5309"
            }
          }

          expect(json_response).to have_attributes(creditcard_base_attributes)
          expect(response.status).to eq(201)
        end

        it "can delete credit cards for other users" do
          # Create a credit card to delete and capture its id.
          api_post :create, user_id: normal_user.id, credit_card: {
            name: "George Costanza",
            cc_type: "discover",
            last_digits: "7890",
            month: 3,
            year: 2086,
            payment_method_id: 1,
            gateway_customer_profile_id: "12345678",
            gateway_payment_profile_id: "abc123",
            address_attributes: {
              firstname: "George",
              lastname: "Costanza",
              address1: "1344 Queens Boulevard",
              address2: "",
              city: "Queens",
              state_name: "New York",
              zipcode: "11375",
              country_iso: "US",
              phone: "867-5309"
            }
          }
          expect(json_response).to have_attributes(creditcard_base_attributes)
          expect(response.status).to eq(201)

          freshly_created_credit_card_id = json_response["id"]

          api_delete :destroy, id: freshly_created_credit_card_id
          expect(response.status).to eq(204)
        end
      end

      context "calling user is not in admin role" do
        let(:current_api_user) do
          normal_user
        end

        let!(:card) { create(:credit_card, user_id: normal_user.id, gateway_customer_profile_id: "random") }

        it "can not view user" do
          api_get :index, user_id: admin_user.id

          expect(response.status).to eq(404)
        end

        it "can view own credit cards" do
          api_get :index, user_id: normal_user.id

          expect(response.status).to eq(200)
          expect(json_response["pages"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["credit_cards"].length).to eq(1)
          expect(json_response["credit_cards"].first["id"]).to eq(card.id)
        end

        it "can create own credit cards" do
          api_post :create, user_id: normal_user.id, credit_card: {
            name: "George Constanza",
            cc_type: "discover",
            last_digits: "7890",
            month: 3,
            year: 2086,
            payment_method_id: 1,
            gateway_customer_profile_id: "12345678",
            gateway_payment_profile_id: "abc123",
            address_attributes: {
              firstname: "George",
              lastname: "Costanza",
              address1: "1344 Queens Boulevard",
              address2: "",
              city: "Queens",
              state_name: "New York",
              zipcode: "11375",
              country_iso: "US",
              phone: "867-5309"
            }
          }
          expect(json_response).to have_attributes(creditcard_base_attributes)
          expect(response.status).to eq(201)
        end

        it "can not create credit cards for other users" do
          api_post :create, user_id: second_normal_user.id, credit_card: {
            name: "Art Vanderlay",
            cc_type: "discover",
            last_digits: "7890",
            month: 3,
            year: 2086,
            payment_method_id: 1,
            gateway_customer_profile_id: "12345678",
            gateway_payment_profile_id: "abc123",
            address_attributes: {
              firstname: "Art",
              lastname: "Vanderlay",
              address1: "1344 Queens Boulevard",
              address2: "",
              city: "Queens",
              state_name: "New York",
              zipcode: "11375",
              country_iso: "US",
              phone: "867-5309"
            }
          }
          # TODO: Why does this get a 404 instead of a 401?
          expect(response.status).to eq(404)
        end
      end

      context "calling user is not in admin role" do
        let(:current_api_user) do
          second_normal_user
        end

        it "can delete own credit cards" do
          api_delete :destroy, id: card_for_successful_delete_attempt.id
          expect(response.status).to eq(204)
        end

        it "can not delete other user's credit cards" do
          api_delete :destroy, id: card_for_unsuccessful_delete_attempt.id
          expect(response.status).to eq(401)
        end
      end
    end

    describe '#update' do
      let(:credit_card) { create(:credit_card, name: 'Joe Shmoe', user: credit_card_user) }
      let(:credit_card_user) { create(:user) }

      before do
        stub_authentication!
      end

      context 'when the user is authorized' do
        let(:current_api_user) { credit_card_user }

        it 'updates the credit card' do
          expect {
            api_put :update, id: credit_card.to_param, credit_card: { name: 'Jordan Brough' }
          }.to change {
            credit_card.reload.name
          }.from('Joe Shmoe').to('Jordan Brough')
        end
      end

      context 'when the user is not authorized' do
        let(:current_api_user) { create(:user) }

        it 'rejects the request' do
          api_put :update, id: credit_card.to_param, credit_card: { name: 'Jordan Brough' }
          expect(response.status).to eq(401)
        end
      end
    end
  end
end