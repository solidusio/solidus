# frozen_string_literal: true

require "spec_helper"

describe SolidusAdmin::BaseController, type: :controller do
  controller(SolidusAdmin::BaseController) do
    def index
      authorize! :update, Spree::Order
      render plain: "test"
    end
  end

  context "unauthorized request" do
    before do
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(nil)
    end

    it "redirects to unauthorized for no user" do
      get :index
      expect(response).to redirect_to "/unauthorized"
    end

    context "with a user without update permission" do
      before do
        user = create(:user, email: "user@example.com")
        allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
      end

      it "redirects to unauthorized" do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  context "authorized request" do
    before do
      user = create(:admin_user, email: "admin@example.com")
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
    end

    it "returns a 200 response" do
      get :index
      expect(response.code).to eq "200"
    end

    it "sets timezone by param" do
      get :index, params: {solidus_timezone: "Hawaii"}
      expect(session).to have_key(:solidus_timezone)
      expect(session[:solidus_timezone]).to eq("Hawaii")
    end
  end

  describe "layout rendering" do
    subject { controller.send(:set_layout) }

    context "with turbo frame request" do
      before do
        allow_any_instance_of(described_class).to receive(:turbo_frame_request?).and_return(true)
      end

      it "renders minimal turbo frame layout" do
        is_expected.to be "turbo_rails/frame"
      end
    end

    context "without turbo frame request" do
      before do
        allow_any_instance_of(described_class).to receive(:turbo_frame_request?).and_return(false)
      end

      it "renders the default layout" do
        is_expected.to eq "solidus_admin/application"
      end
    end
  end

  describe "logout path" do
    subject { controller.send(:solidus_admin_logout_path) }

    context "with a configured logout path" do
      before do
        allow(SolidusAdmin::Config).to receive(:logout_link_path).and_return("/sign_out")
      end

      it "uses the configured path" do
        is_expected.to eq "/sign_out"
      end
    end

    context "without a configured logout path" do
      before do
        allow(SolidusAdmin::Config).to receive(:logout_link_path).and_return(nil)
      end

      it "uses the backend logout path, wherever the backend is mounted" do
        allow(controller).to receive(:spree).and_return(double(admin_logout_path: "/store/admin/logout"))

        is_expected.to eq "/store/admin/logout"
      end

      it "falls back to /admin/logout when the backend has no logout route" do
        allow(controller).to receive(:spree).and_return(double)

        is_expected.to eq "/admin/logout"
      end
    end
  end
end
