
require "spec_helper"

RSpec.describe "Legacy Solidus Admin", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #admin/products" do
    it "returns a successful response" do
      get "/admin/products"
      binding.irb
      expect(response).to have_http_status(:success)
    end
  end
end
