# frozen_string_literal: true

require "spec_helper"

describe "Store", type: :feature, js: true do
  stub_authorization!

  let!(:store) do
    create(:store, name: "Test Store", url: "test.example.org",
      mail_from_address: "test@example.org")
  end

  let!(:vat_country) { create(:country, iso: "DE", name: "Germany") }
  let!(:store_country) { create(:country, iso: "AT", states_required: false) }

  before(:each) do
    visit spree.admin_path
    click_nav "Settings", "Stores"
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
      fill_in "store_mail_from_address", with: "solidus@example.org"
      click_button "Update"

      expect(page).to have_content "successfully updated"
      expect(page).to have_field("store_name", with: "Spree Demo Site99")
      expect(page).to have_field("store_mail_from_address", with: "solidus@example.org")
    end

    it "should be able to update the default cart tax country" do
      expect(page).to have_select("Tax Country for Empty Carts", selected: "No taxes on carts without address")

      select "Germany", from: "Tax Country for Empty Carts"
      click_button "Update"

      expect(page).to have_content("has been successfully updated")
      expect(page).to have_select("Tax Country for Empty Carts", selected: "Germany")
    end
  end

  context "editing the store address" do
    it "should be able to save the address" do
      within("[data-hook='store_address_wrapper']") do
        expect(page).not_to have_field("Email")
        fill_in "Name", with: "Test Store Inc."
        fill_in "Street Address", with: "1 Store Street"
        fill_in "City", with: "Storetown"
        fill_in "Zip Code", with: "12345"
        fill_in "Phone", with: "555-555-0199"
        select "Austria", from: "Country"
      end
      click_button "Update"

      expect(page).to have_content("has been successfully updated")
      expect(store.reload.address).to have_attributes(
        name: "Test Store Inc.",
        address1: "1 Store Street",
        country: store_country
      )
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
