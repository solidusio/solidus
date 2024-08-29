# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/bulk_delete_resources"

describe "Properties", type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists properties and allows deleting them", :js do
    create(:property, name: "Type prop", presentation: "Type prop")
    create(:property, name: "Size", presentation: "Size")

    visit "/admin/properties"
    expect(page).to have_content("Type prop")
    expect(page).to have_content("Size")

    expect(page).to be_axe_clean

    select_row("Type prop")
    click_on "Delete"
    expect(page).to have_content("Properties were successfully removed.")
    expect(page).not_to have_content("Type prop")
    expect(Spree::Property.count).to eq(1)
  end

  context "creating a new property" do
    it "creates a new product property" do
      visit "/admin/properties"
      click_on "Add new"

      fill_in "Name", with: "Color"
      fill_in "Presentation", with: "Cool Color"
      click_on "Add Property"

      expect(page).to have_content("Property was successfully created.")
      expect(page).to have_content("Color")
      expect(page).to have_content("Cool Color")
      expect(Spree::Property.count).to eq(1)
    end

    it "shows validation errors" do
      visit "/admin/properties"
      click_on "Add new"

      fill_in "Name", with: ""
      click_on "Add Property"

      expect(page).to have_content("can't be blank")
      expect(Spree::Property.count).to eq(0)
    end
  end

  context "editing an existing property" do
    let!(:property) { create(:property, name: "Color", presentation: "Cool Color") }

    it "updates the property" do
      visit "/admin/properties"
      click_on "Color"

      fill_in "Name", with: "Size"
      fill_in "Presentation", with: "Cool Size"
      click_on "Update Property"

      expect(page).to have_content("Property was successfully updated.")
      expect(page).to have_content("Size")
      expect(page).to have_content("Cool Size")
      expect(Spree::Property.count).to eq(1)
    end

    it "shows validation errors" do
      visit "/admin/properties"
      click_on "Color"
      expect(page).to have_field("Name", with: "Color")
      fill_in "Name", with: ""
      click_on "Update Property"

      expect(page).to have_content("can't be blank")
      expect(Spree::Property.count).to eq(1)
    end
  end
end
