# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Promotion Codes" do
  stub_authorization!

  describe "create" do
    let(:promotion) { create :promotion }

    before do
      visit spree.new_admin_promotion_promotion_code_path(promotion)
    end

    it "creates a new promotion code" do
      fill_in "Value", with: "XYZ"
      click_button "Create"

      expect(page).to have_content "Promotion Code has been successfully created!"
    end

    it "disables the button at submit" do
      expect(page).to have_css("input[type='submit'][data-disable-with='Create']")
    end
  end
end
