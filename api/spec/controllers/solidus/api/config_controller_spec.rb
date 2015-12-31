require 'spec_helper'

module Spree
  describe Api::ConfigController, :type => :controller do
    render_views

    before do
      stub_authentication!
    end

    it "returns Solidus::Money settings" do
      api_get :money
      expect(response).to be_success
      expect(json_response["symbol"]).to eq("$")
    end

    it "returns some configuration settings" do
      api_get :show
      expect(response).to be_success
      expect(json_response["default_country_id"]).to eq(Solidus::Config[:default_country_id])
    end
  end
end
