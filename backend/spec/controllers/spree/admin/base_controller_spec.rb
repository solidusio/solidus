# Spree's rpsec controller tests get the Spree::ControllerHacks
# we don't need those for the anonymous controller here, so
# we call process directly instead of get
require 'spec_helper'

describe Spree::Admin::BaseController do
  controller(Spree::Admin::BaseController) do
    def index
      authorize! :update, Spree::Order
      render :text => 'test'
    end
  end

  context "unauthorized request" do
    before do
      Spree::Admin::BaseController.any_instance.stub(:spree_current_user).and_return(nil)
    end

    it "checks error" do
      allow(controller).to receive_message_chain(:spree, :root_path).and_return('/rooot')
      get :index
      expect(response).to redirect_to "/rooot"
    end
  end
end
