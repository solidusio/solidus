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

      let!(:card) { create(:credit_card, user_id: admin_user.id, gateway_customer_profile_id: "random") }

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
            gateway_payment_profile_id: "abc123"
          }
          expect(json_response).to have_attributes(creditcard_base_attributes)
          expect(response.status).to eq(201)

        end

        it "can delete credit cards for other users" do

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

        end

        it "can not create credit cards for other users" do

        end

        it "can delete own credit cards" do

        end

        it "can not delete other user's credit cards" do

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

    # describe '#destroy' do
    #   it ""
    # end

  end
end
