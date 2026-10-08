# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::StatesController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    before { create_list(:state, 3) }

    it "serves json with a 200 OK status" do
      get solidus_admin.states_path
      expect(response.headers["Content-Type"]).to include("application/json")
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "GET /index pagination headers" do
    it "links to the next page while more states remain" do
      allow_any_instance_of(SolidusAdmin::StatesController).to receive(:per_page).and_return(2)
      create_list(:state, 3)

      get solidus_admin.states_path(view: "state_with_country")

      expect(response.headers["X-Total-Count"]).to eq("3")
      expect(response.headers["Link"]).to eq(
        %(<http://www.example.com/admin/states?page=2&view=state_with_country>; rel="next")
      )
    end

    it "sends no next link on the last page" do
      create_list(:state, 3)

      get solidus_admin.states_path

      expect(response.headers["X-Total-Count"]).to eq("3")
      expect(response.headers["Link"]).to be_nil
    end
  end
end
