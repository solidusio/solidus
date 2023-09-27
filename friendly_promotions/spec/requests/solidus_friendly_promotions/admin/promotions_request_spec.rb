# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Admin::Promotions", type: :request do
  describe "GET /index" do
    stub_authorization!

    it "is successful" do
      get admin_promotions_path
      expect(response).to be_successful
    end
  end
end
