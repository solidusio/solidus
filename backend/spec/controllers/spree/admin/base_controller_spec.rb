# frozen_string_literal: true

require "spec_helper"

describe Spree::Admin::BaseController, type: :controller do
  controller(Spree::Admin::BaseController) do
    def index
      authorize! :update, Spree::Order
      render plain: "test"
    end
  end

  context "unauthorized request" do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(nil)
    end

    it "redirects to unauthorized" do
      get :index
      expect(response).to redirect_to "/unauthorized"
    end

    context "when an unauthorized redirect handler is provided" do
      around do |example|
        old_redirect_lambda = Spree::Admin::BaseController.unauthorized_redirect
        Spree.deprecator.silence do
          Spree::Admin::BaseController.unauthorized_redirect = -> { redirect_to "/custom_unauthorized" }
        end
        example.run
        Spree.deprecator.silence do
          Spree::Admin::BaseController.unauthorized_redirect = old_redirect_lambda
        end
      end

      it "redirects to the custom unauthorized path" do
        get :index
        expect(response).to redirect_to "/custom_unauthorized"
      end
    end
  end
end
