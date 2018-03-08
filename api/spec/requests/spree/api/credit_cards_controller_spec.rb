# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::CreditCardsController, type: :request do
    describe '#index' do
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
        get spree.api_user_credit_cards_path(1000)
        expect(response.status).to eq(404)
      end

      context "calling user is in admin role" do
        let(:current_api_user) do
          admin_user
        end

        it "no credit cards exist for user" do
          get spree.api_user_credit_cards_path(normal_user)

          expect(response.status).to eq(200)
          expect(json_response["pages"]).to eq(0)
        end

        it "can view all credit cards for user" do
          get spree.api_user_credit_cards_path(current_api_user.id)

          expect(response.status).to eq(200)
          expect(json_response["pages"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["credit_cards"].length).to eq(1)
          expect(json_response["credit_cards"].first["id"]).to eq(card.id)
        end
      end

      context "calling user is not in admin role" do
        let(:current_api_user) do
          normal_user
        end

        let!(:card) { create(:credit_card, user_id: normal_user.id, gateway_customer_profile_id: "random") }

        it "can not view user" do
          get spree.api_user_credit_cards_path(admin_user.id)

          expect(response.status).to eq(404)
        end

        it "can view own credit cards" do
          get spree.api_user_credit_cards_path(normal_user.id)

          expect(response.status).to eq(200)
          expect(json_response["pages"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["credit_cards"].length).to eq(1)
          expect(json_response["credit_cards"].first["id"]).to eq(card.id)
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
            put spree.api_credit_card_path(credit_card.to_param), params: { credit_card: { name: 'Jordan Brough' } }
          }.to change {
            credit_card.reload.name
          }.from('Joe Shmoe').to('Jordan Brough')
        end
      end

      context 'when the user is not authorized' do
        let(:current_api_user) { create(:user) }

        it 'rejects the request' do
          put spree.api_credit_card_path(credit_card.to_param), params: { credit_card: { name: 'Jordan Brough' } }
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
