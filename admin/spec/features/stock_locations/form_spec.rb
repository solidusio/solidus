# frozen_string_literal: true

require 'spec_helper'

describe "Stock Location Form", :js, type: :feature do
  before do
    %w[US CA].each do |iso|
      create(:country, iso:).tap { create(:state, country: _1, name: "Fictitious State in #{iso}") }
    end

    sign_in create(:admin_user, email: 'admin@example.com')
    visit "/admin/stock_locations"
    click_on "Add new"
  end

  it 'shows page with form for stock location' do
    expect(page).to have_current_path(solidus_admin.new_stock_location_path)
    expect(page).to have_content("New Stock Location")
    expect(page).to have_content("Address")
    expect(page).to have_content("Availability")
    expect(page).to have_content("Setup")
    expect(page).to have_content("Save", count: 2)
    expect(page).to have_content("Discard")
    expect(page).to be_axe_clean
  end

  describe 'navigation buttons' do
    it 'allows to go back' do
      click_on 'Back'
      expect(page).to have_current_path(solidus_admin.stock_locations_path)
    end

    it 'allows to discard changes' do
      click_on 'Discard'
      expect(page).to have_current_path(solidus_admin.stock_locations_path)
    end
  end

  it "renders checkboxes with default values" do
    expect(checkbox("Active")).to be_checked
    expect(checkbox("Propagate all variants")).to be_checked
    expect(checkbox("Restock inventory")).to be_checked
    expect(checkbox("Fulfillable")).to be_checked
    expect(checkbox("Check stock on transfer")).to be_checked

    expect(checkbox("Set as default for all products")).not_to be_checked
    expect(checkbox("Backorderable default")).not_to be_checked
  end

  it "preselects default country" do
    expect(solidus_select_control("Country")).to have_content("United States")
  end

  describe "submit" do
    context "with valid inputs" do
      it "saves changes" do
        aggregate_failures do
          fill_in "Name", with: "Warehouse"
          fill_in "Internal Name", with: "warehouse"
          fill_in "Code", with: "wrhs"
          fill_in "Street Address", with: "Willow St."
          fill_in "Street Address (cont'd)", with: "12/21"
          fill_in "City", with: "12/21"
          fill_in "Zip", with: "12-345"
          solidus_select "Canada", from: "Country"
          solidus_select "Fictitious State in CA", from: "State"
          fill_in "Phone", with: "123123123"
          check "Set as default for all products"
          check "Backorderable default"

          within("header") { click_on "Save" }

          expect(page).to have_current_path(solidus_admin.stock_locations_path)
          expect(page).to have_content("Stock location was successfully created.")

          click_on "Warehouse"

          expect(page).to have_current_path(solidus_admin.edit_stock_location_path(Spree::StockLocation.last))
          expect(find_field("Name").value).to eq "Warehouse"
          expect(find_field("Internal Name").value).to eq "warehouse"
          expect(find_field("Code").value).to eq "wrhs"
          expect(find_field("Street Address").value).to eq "Willow St."
          expect(find_field("Street Address (cont'd)").value).to eq "12/21"
          expect(find_field("City").value).to eq "12/21"
          expect(find_field("Zip").value).to eq "12-345"
          expect(solidus_select_control("Country")).to have_content("Canada")
          expect(solidus_select_control("State")).to have_content("Fictitious State in CA")
          expect(find_field("Phone").value).to eq "123123123"
          expect(checkbox("Active")).to be_checked
          expect(checkbox("Propagate all variants")).to be_checked
          expect(checkbox("Restock inventory")).to be_checked
          expect(checkbox("Fulfillable")).to be_checked
          expect(checkbox("Check stock on transfer")).to be_checked
          expect(checkbox("Set as default for all products")).to be_checked
          expect(checkbox("Backorderable default")).to be_checked

          fill_in "Name", with: "Warehouse (inactive)"
          uncheck "Active"
          uncheck "Propagate all variants"
          uncheck "Restock inventory"
          uncheck "Fulfillable"
          uncheck "Check stock on transfer"
          uncheck "Set as default for all products"
          uncheck "Backorderable default"

          within("header") { click_on "Save" }

          expect(page).to have_current_path(solidus_admin.stock_locations_path)
          expect(page).to have_content("Stock location was successfully updated.")

          click_on "Warehouse (inactive)"

          expect(checkbox("Active")).not_to be_checked
          expect(checkbox("Propagate all variants")).not_to be_checked
          expect(checkbox("Restock inventory")).not_to be_checked
          expect(checkbox("Fulfillable")).not_to be_checked
          expect(checkbox("Check stock on transfer")).not_to be_checked
          expect(checkbox("Set as default for all products")).not_to be_checked
          expect(checkbox("Backorderable default")).not_to be_checked
        end
      end
    end

    context "with invalid inputs" do
      it "shows validation errors" do
        within("header") { click_on "Save" }
        expect(page).to have_content("can't be blank")
      end
    end
  end
end
