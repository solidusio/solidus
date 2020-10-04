# frozen_string_literal: true

require 'spec_helper'

describe Spree::Api::StoreCreditEventsController, type: :request do
  let(:api_user) { create(:user, :with_api_key) }

  describe "GET mine" do
    subject do
      get spree.mine_api_store_credit_events_path(format: :json), headers: { Authorization: "Bearer #{api_key}" }
    end

    context "no current api user" do
      let(:api_key) { nil }

      before { subject }

      it "returns a 401" do
        expect(response.status).to eq 401
      end
    end

    context "the current api user is authenticated" do
      let(:current_api_user) { create(:user, :with_api_key) }
      let(:api_key) { current_api_user.spree_api_key }

      context "the user doesn't have store credit" do
        before { subject }

        it "should set the events variable to empty list" do
          expect(json_response["store_credit_events"]).to eq []
        end

        it "returns a 200" do
          expect(response.status).to eq 200
        end
      end

      context "the user has store credit" do
        let!(:store_credit) { create(:store_credit, user: current_api_user) }

        before { subject }

        it "should contain the store credit allocation event" do
          expect(json_response["store_credit_events"].size).to eq 1
          expect(json_response["store_credit_events"][0]).to include(
            "display_amount" => "$150.00",
            "display_user_total_amount" => "$150.00",
            "display_action" => "Added"
          )
        end

        it "returns a 200" do
          expect(response.status).to eq 200
        end
      end
    end
  end
end
