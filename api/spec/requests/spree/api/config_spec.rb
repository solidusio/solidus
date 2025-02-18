# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe "Configuration", type: :request do
    let!(:default_country) { create :country, iso: "US" }

    before do
      stub_authentication!
    end

    it "returns Spree::Money settings" do
      get "/api/config/money"
      expect(response).to be_successful
      expect(json_response["symbol"]).to eq("$")
    end

    it "returns some configuration settings" do
      get "/api/config"
      expect(response).to be_successful
      expect(json_response["default_country_iso"]).to eq("US")
    end
  end
end
