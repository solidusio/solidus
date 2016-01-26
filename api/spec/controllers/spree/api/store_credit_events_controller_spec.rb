require 'spec_helper'

describe Spree::Api::StoreCreditEventsController, type: :controller do
  render_views

  let(:api_user) { create(:user) }

  before do
    allow(controller).to receive(:load_user)
    controller.instance_variable_set(:@current_api_user, api_user)
  end

  describe "GET mine" do
    subject { api_get :mine, { format: :json } }

    before { allow(controller).to receive_messages(current_api_user: current_api_user) }

    context "no current api user" do
      let(:current_api_user) { nil }

      before { subject }

      it "returns a 401" do
        expect(response.status).to eq 401
      end
    end

    context "the current api user is authenticated" do
      let(:current_api_user) { order.user }
      let(:order) { create(:order, line_items: [line_item]) }

      context "the user doesn't have store credit" do
        let(:current_api_user) { create(:user) }

        before { subject }

        it "should set the events variable to empty list" do
          expect(assigns(:store_credit_events)).to eq []
        end

        it "returns a 200" do
          expect(subject.status).to eq 200
        end
      end

      context "the user has store credit" do
        let(:store_credit)     { create(:store_credit, user: api_user) }
        let(:current_api_user) { store_credit.user }

        before { subject }

        it "should contain one store credit event" do
          expect(assigns(:store_credit_events).size).to eq 1
        end

        it "should contain the store credit allocation event" do
          expect(assigns(:store_credit_events).first).to eq store_credit.store_credit_events.first
        end

        it "returns a 200" do
          expect(subject.status).to eq 200
        end
      end
    end
  end
end
