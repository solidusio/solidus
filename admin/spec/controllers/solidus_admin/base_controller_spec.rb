# frozen_string_literal: true

require "spec_helper"

describe SolidusAdmin::BaseController, type: :controller do
  controller(SolidusAdmin::BaseController) do
    def index
      authorize! :update, Spree::Order
      render plain: 'test'
    end
  end

  context "unauthorized request" do
    before do
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(nil)
    end

    it "redirects to unauthorized for no user" do
      get :index
      expect(response).to redirect_to '/unauthorized'
    end

    context "with a user without update permission" do
      before do
        user = create(:user, email: 'user@example.com')
        allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
      end

      it "redirects to unauthorized" do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  context "successful request" do
    before do
      user = create(:admin_user, email: 'admin@example.com')
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
    end

    it "returns a 200 response" do
      get :index
      expect(response.code).to eq "200"
    end
  end
end
