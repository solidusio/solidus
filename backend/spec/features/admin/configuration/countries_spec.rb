require 'spec_helper'

module Spree
  describe "Countries", type: :feature do
    stub_authorization!

    it "deletes a country", js: true do
      visit spree.admin_countries_path
      click_link "New Country"

      fill_in "Name", with: "Brazil"
      fill_in "ISO Name", with: "BRL"
      click_button "Create"

      accept_alert do
        click_icon :trash
      end

      expect(page).to have_content 'Country "Brazil" has been successfully removed!'
    end
  end
end
