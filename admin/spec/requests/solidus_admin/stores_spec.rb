# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::StoresController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
    allow(admin_user).to receive(:has_spree_role?).with('admin').and_return(true)
  end

  let(:resource_class) { Spree::Store }
  let(:valid_attributes) { { name: "New Store", code: "new-store" } }
  let(:invalid_attributes) { { name: "", code: "", domain: "" } }

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_store_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    let(:store) { create(:store) }

    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_store_path(store)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Strong Parameters" do
    it "permits the expected parameters" do
      params = ActionController::Parameters.new(store: { store_id: 1, name: "Test Store", code: "test-store" })
      permitted_params = params.require(:store).permit(:store_id, :name, :code)
      expect(permitted_params.keys).to contain_exactly("store_id", "name", "code")
    end
  end
end
