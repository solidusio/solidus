# frozen_string_literal: true

# Spree's rpsec controller tests get the Spree::ControllerHacks
# we don't need those for the anonymous controller here, so
# we call process directly instead of get
require 'spec_helper'

describe Spree::Admin::BaseController, type: :controller do
  controller(Spree::Admin::BaseController) do
    def index
      authorize! :update, Spree::Order
      render plain: 'test'
    end
  end

  context "unauthorized request" do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:try_spree_current_user).and_return(nil)
    end

    it "redirects to unauthorized" do
      get :index
      expect(response).to redirect_to '/unauthorized'
    end
  end
end
