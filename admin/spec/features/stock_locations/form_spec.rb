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
    expect(page).to have_content("New Stock location")
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
    expect(checkbox("Propagate All Variants")).to be_checked
    expect(checkbox("Restock Inventory")).to be_checked
    expect(checkbox("Fulfillable")).to be_checked
    expect(checkbox("Check Stock on Transfer")).to be_checked

    expect(checkbox("Default")).not_to be_checked
    expect(checkbox("Backorderable Default")).not_to be_checked
  end

  it "preselects default country" do
    expect(find(:select, name: "stock_location[country_id]").find(:option, selected: true)).to have_content("United States")
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
          select "Canada", from: "stock_location[country_id]"
          select "Fictitious State in CA", from: "stock_location[state_id]"
          fill_in "Phone", with: "123123123"
          check "Default"
          check "Backorderable Default"

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
          expect(selected_option("stock_location[country_id]")).to have_content("Canada")
          expect(selected_option("stock_location[state_id]")).to have_content("Fictitious State in CA")
          expect(find_field("Phone").value).to eq "123123123"
          expect(checkbox("Active")).to be_checked
          expect(checkbox("Propagate All Variants")).to be_checked
          expect(checkbox("Restock Inventory")).to be_checked
          expect(checkbox("Fulfillable")).to be_checked
          expect(checkbox("Check Stock on Transfer")).to be_checked
          expect(checkbox("Default")).to be_checked
          expect(checkbox("Backorderable Default")).to be_checked

          fill_in "Name", with: "Warehouse (inactive)"
          uncheck "Active"
          uncheck "Propagate All Variants"
          uncheck "Restock Inventory"
          uncheck "Fulfillable"
          uncheck "Check Stock on Transfer"
          uncheck "Default"
          uncheck "Backorderable Default"

          within("header") { click_on "Save" }

          expect(page).to have_current_path(solidus_admin.stock_locations_path)
          expect(page).to have_content("Stock location was successfully updated.")

          click_on "Warehouse (inactive)"

          expect(checkbox("Active")).not_to be_checked
          expect(checkbox("Propagate All Variants")).not_to be_checked
          expect(checkbox("Restock Inventory")).not_to be_checked
          expect(checkbox("Fulfillable")).not_to be_checked
          expect(checkbox("Check Stock on Transfer")).not_to be_checked
          expect(checkbox("Default")).not_to be_checked
          expect(checkbox("Backorderable Default")).not_to be_checked
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
