# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::StoreCreditsController, type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }
  let!(:store_credit) { create(:store_credit, user: user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /store_credits" do
    it "renders the store credits template with a 200 OK status" do
      get solidus_admin.store_credits_user_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(store_credit.amount.to_s)
    end
  end
end
