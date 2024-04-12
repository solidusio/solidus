# frozen_string_literal: true

require 'spec_helper'

describe "Shipping Categories", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists shipping categories and allows deleting them" do
    create(:shipping_category, name: "Default-shipping")

    visit "/admin/shipping_categories"
    expect(page).to have_content("Default-shipping")
    expect(page).to be_axe_clean

    select_row("Default-shipping")
    click_on "Delete"
    expect(page).to have_content("Shipping categories were successfully removed.")
    expect(page).not_to have_content("Default-shipping")
    expect(Spree::ShippingCategory.count).to eq(0)
    expect(page).to be_axe_clean
  end

  context "edition" do
    before do
      Spree::ShippingCategory.create(name: "a shipping category")
    end

    it "allows to edit a shipping category" do
      visit "/admin/shipping_categories"
      find_row("a shipping category").click()

      expect(page).to have_content("Edit Shipping Category")

      fill_in "Name", with: "a new name"

      click_on "Update Shipping Category"
      expect(page).to have_content("Shipping category was successfully updated.")
      expect(Spree::ShippingCategory.find_by(name: "a new name")).to be_present
    end
  end

  context "when creating a new shipping category" do
    let(:query) { "?page=1&q%5Bname_or_description_cont%5D=What" }

    before do
      visit "/admin/shipping_categories#{query}"
      click_on "Add new"
      expect(page).to have_content("New Shipping Category")
      expect(page).to be_axe_clean
    end

    it "opens a modal" do
      expect(page).to have_selector("dialog")
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
      expect(page.current_url).to include(query)
    end

    context "with valid data" do
      it "successfully creates a new shipping category, keeping page and q params" do
        fill_in "Name", with: "Whatever"

        click_on "Add Shipping Category"

        expect(page).to have_content("Shipping category was successfully created.")
        expect(Spree::ShippingCategory.find_by(name: "Whatever")).to be_present
        expect(page.current_url).to include(query)
      end
    end

    context "with invalid data" do
      it "fails to create a new shipping category, keeping page and q params" do
        click_on "Add Shipping Category"

        expect(page).to have_content "can't be blank"
        expect(page.current_url).to include(query)
      end
    end
  end
end
