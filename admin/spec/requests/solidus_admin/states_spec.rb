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
end
