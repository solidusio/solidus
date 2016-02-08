require 'spec_helper'

module Spree
  describe Api::ConfigController, type: :controller do
    let!(:default_country) { create :country, iso: "US"}
    render_views

    before do
      stub_authentication!
    end

    it "returns Spree::Money settings" do
      api_get :money
      expect(response).to be_success
      expect(json_response["symbol"]).to eq("$")
    end

    it "returns some configuration settings" do
      api_get :show
      expect(response).to be_success
      expect(json_response["default_country_iso"]).to eq("US")
      expect(json_response["default_country_id"]).to eq(default_country.id)
    end
  end
end
