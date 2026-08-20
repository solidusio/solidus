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

  describe "#per_page" do
    it "returns SolidusAdmin::Config.per_page" do
      allow(SolidusAdmin::Config).to receive(:per_page).and_return(35)
      expect(controller.send(:per_page)).to eq(35)
    end
  end

  describe "#set_page_and_extract_portion_from" do
    it "passes per_page to geared_pagination" do
      records = Spree::Order.all
      allow(SolidusAdmin::Config).to receive(:per_page).and_return(15)
      controller.send(:set_page_and_extract_portion_from, records)
      expect(controller.instance_variable_get(:@page).recordset.ratios.fixed).to eq(15)
    end
  end
end
