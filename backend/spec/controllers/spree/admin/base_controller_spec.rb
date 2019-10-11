# frozen_string_literal: true

# Spree's rpsec controller tests get the Solidus::ControllerHacks
# we don't need those for the anonymous controller here, so
# we call process directly instead of get
require 'spec_helper'

describe Solidus::Admin::BaseController, type: :controller do
  controller(Solidus::Admin::BaseController) do
    def index
      authorize! :update, Solidus::Order
      render plain: 'test'
    end
  end

  context "unauthorized request" do
    before do
      allow_any_instance_of(Solidus::Admin::BaseController).to receive(:try_spree_current_user).and_return(nil)
    end

    it "redirects to unauthorized" do
      get :index
      expect(response).to redirect_to '/unauthorized'
    end
  end
end
