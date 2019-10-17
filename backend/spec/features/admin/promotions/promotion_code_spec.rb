# frozen_string_literal: true

require "spec_helper"

feature "Promotion Codes" do
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

    it "disables the button at submit", :js do
      page.execute_script "$('form').submit(function(e) { e.preventDefault()})"

      fill_in "Value", with: "XYZ"
      click_button "Create"

      expect(page).to have_button("Create", disabled: true)
    end
  end
end
