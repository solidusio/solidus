# frozen_string_literal: true

require 'spec_helper'

describe "Stores", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  describe "index page" do
    before do
      create(:store, name: "B2C Store")
      create(:store, name: "B2B Store", default: true)
      visit "/admin/stores"
      expect(page).to have_content("B2C Store")
      expect(page).to have_content("B2B Store")
      expect(page).to be_axe_clean
    end

    it "lists stores and allows deleting them" do
      select_row("B2C Store")

      accept_confirm("Are you sure you want to delete 1 store?") do
        click_button("Delete")
      end

      expect(page).to have_content("Stores were successfully removed.")
      expect(page).not_to have_content("B2C Store")
      expect(page).to be_axe_clean
    end

    it "does not allow to delete default store" do
      select_row("B2B Store")

      accept_confirm("Are you sure you want to delete 1 store?") do
        click_button("Delete")
      end

      expect(page).not_to have_content("Stores were successfully removed.")
      expect(page).to have_content("B2B Store")
      expect(page).to have_content("Some Stores could not be removed")
      expect(page).to have_content("B2B Store: Cannot destroy the default Store")
      expect(page).to be_axe_clean
    end
  end

  describe "creating new store" do
    before do
      visit "/admin/stores"
      click_on "Add new"
      expect(page).to be_axe_clean
    end

    context "with valid form" do
      it "saves store" do
        fill_in "Store Name", with: "New Store"
        fill_in "Slug", with: "new-store"
        fill_in "URL", with: "www.new-store.com"
        fill_in "Store Email", with: "mail@new-stores.com"

        within("header") { click_on "Save" }

        expect(page).to have_content("Store was successfully created")
        expect(page).to have_content("New Store")
        expect(page).to have_content("new-store")
        expect(page).to have_content("www.new-store.com")
      end
    end

    context "with invalid form" do
      it "saves store" do
        within("header") { click_on "Save" }

        expect(page).to have_content("can't be blank", count: 4)
      end
    end
  end

  describe "editing existing store" do
    before do
      create(:store,
        name: "B2C Store",
        default_currency: "GBP",
        cart_tax_country_iso: create(:country, iso: "GB").iso,
        available_locales: %w[en])

      create(:country, iso: "US")
      visit "/admin/stores"
      click_on "B2C Store"
      expect(page).to be_axe_clean
    end

    it "updates store" do
      expect(solidus_select_control("Default Currency")).to have_content("GBP")
      expect(solidus_select_control("Tax Country")).to have_content("United Kingdom")
      expect(solidus_select_control("Storefront Languages")).to have_content("English (US)")

      fill_in "Store Name", with: "Updated Store"
      fill_in "Slug", with: "updated-store"
      fill_in "URL", with: "www.updated-store.com"
      fill_in "Store Email", with: "updated-mail@new-stores.com"
      solidus_select("USD", from: "Default Currency")
      solidus_select("United States", from: "Tax Country")

      within("header") { click_on "Save" }

      expect(page).to have_content("Store was successfully updated")
      expect(page).to have_content("Updated Store")
      expect(page).to have_content("updated-store")
      expect(page).to have_content("www.updated-store.com")

      click_on "Updated Store"
      expect(solidus_select_control("Default Currency")).to have_content("USD")
      expect(solidus_select_control("Tax Country")).to have_content("United States")
    end
  end

  describe "clicking Discard" do
    it "redirects back to index" do
      visit "/admin/stores"
      click_on "Add new"
      click_on "Discard"
      expect(page).to have_current_path("/admin/stores")
    end
  end
end
