# frozen_string_literal: true

require 'spec_helper'

describe "Shipping Methods", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists shipping methods and allows deleting them", :js do
    create(:shipping_method, name: "FAAAST")

    visit "/admin/shipping_methods"
    expect(page).to have_content("FAAAST")
    expect(page).to be_axe_clean

    select_row("FAAAST")
    click_on "Delete"

    expect(page).to have_content("Shipping methods were successfully removed.")
    expect(page).not_to have_content("FAAAST")
    expect(Spree::ShippingMethod.count).to eq(0)
    expect(page).to be_axe_clean
  end

  it "shows the link for creating a new shipping method" do
    visit "/admin/shipping_methods"

    expect(page).to have_content("Add new")
    expect(page).to have_selector(:css, 'a[href="/admin/shipping_methods/new"]')
  end

  context "when creating a new shipping method" do
    before do
      create(:shipping_category, name: "Default")

      visit "/admin/shipping_methods/new"
    end

    it "creates the shipping method", :js do
      fill_in "Name", with: "Super Saver"
      fill_in "Code", with: "super-saver"
      fill_in "Carrier", with: "CarrierX"
      fill_in "Tracking URL", with: "https://track.example.com/:tracking"

      check "Available to all stock locations"
      check "Available to users"
      solidus_select "Default", from: "Shipping Categories"

      click_on "Save"

      expect(page).to have_content("Shipping method was successfully created.")
      expect(Spree::ShippingMethod.find_by(name: "Super Saver")).to be_present
    end
  end

  context "when editing an existing shipping method" do
    let!(:shipping_method) { create(:shipping_method, name: "Old Name") }

    before { visit spree.edit_admin_shipping_method_path(shipping_method) }

    it "updates the shipping method", :js do
      fill_in "Name", with: "New Name"
      click_on "Save"

      expect(page).to have_content("Shipping method was successfully updated.")
      expect(page).to have_content("New Name")
    end
  end
end
