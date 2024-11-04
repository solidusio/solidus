# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Promotion Codes", partial_double_verification: false do
  stub_authorization!

  describe "Admin" do
    let(:promotion) { create :solidus_promotion, code: "10off" }

    before do
      allow_any_instance_of(ApplicationController).to receive(:spree_current_user) { build(:user, id: 123) }
      visit solidus_promotions.admin_promotion_promotion_codes_path(promotion)
    end

    it "renders any promotion codes' " do
      expect(page).to have_content("10off")
    end

    it "creates new promotion codes" do
      click_link "Create promotion code"
      fill_in "promotion_code_value", with: "20off"
      click_button "Create"
      expect(page).to have_content("Promotion code has been successfully created!")
    end

    context "when downloading a CSV" do
      let!(:promotion_code) { create :solidus_promotion_code, promotion: promotion }

      it "downloads a CSV file with the promotion codes" do
        click_link "Download codes list"
        expect(page.response_headers["Content-Type"]).to eq("text/csv")
        expect(page.response_headers["Content-Disposition"]).to include("attachment")
        expect(page.response_headers["Content-Disposition"]).to include("promotion-code-list-#{promotion.id}.csv")
        expect(page.body).to include(promotion_code.value)
      end
    end
  end
end
