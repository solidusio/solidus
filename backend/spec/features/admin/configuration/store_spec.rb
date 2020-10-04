# frozen_string_literal: true

require 'spec_helper'

describe "Store", type: :feature, js: true do
  stub_authorization!

  let!(:store) do
    create(:store, name: 'Test Store', url: 'test.example.org',
           mail_from_address: 'test@example.org')
  end

  let!(:vat_country) { create(:country, iso: "DE", name: "Germany") }

  before(:each) do
    visit spree.admin_path
    click_link "Settings"
    within('.admin-nav') do
      click_link "Stores"
    end
  end

  context "visiting general store settings" do
    it "should have the right content" do
      expect(page).to have_field("store_name", with: "Test Store")
      expect(page).to have_field("store_url", with: "test.example.org")
      expect(page).to have_field("store_mail_from_address", with: "test@example.org")
    end
  end

  context "editing general store settings" do
    it "should be able to update the site name" do
      fill_in "store_name", with: "Spree Demo Site99"
      fill_in "store_mail_from_address", with: "spree@example.org"
      click_button "Update"

      expect(page).to have_content "successfully updated"
      expect(page).to have_field("store_name", with: "Spree Demo Site99")
      expect(page).to have_field("store_mail_from_address", with: "spree@example.org")
    end

    it "should be able to update the default cart tax country" do
      expect(page).to have_select('Tax Country for Empty Carts', selected: 'No taxes on carts without address')

      select "Germany", from: "Tax Country for Empty Carts"
      click_button "Update"

      expect(page).to have_content("has been successfully updated")
      expect(page).to have_select("Tax Country for Empty Carts", selected: "Germany")
    end
  end

  context "update fails" do
    it "should display the error" do
      fill_in "Site Name", with: " "
      click_button "Update"

      expect(page).to have_content("can't be blank")
      expect(page).to have_field("Site Name", with: " ")
    end
  end
end
