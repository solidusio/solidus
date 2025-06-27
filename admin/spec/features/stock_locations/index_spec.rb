# frozen_string_literal: true

require 'spec_helper'

describe "Stock Locations", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists stock locations and allows deleting them" do
    create(:stock_location, name: "Default-location")

    visit "/admin/stock_locations"
    expect(page).to have_content("Default-location")
    expect(page).to be_axe_clean

    select_row("Default-location")
    click_on "Delete"
    expect(page).to have_content("Stock locations were successfully removed.")
    expect(page).not_to have_content("Default-location")
    expect(Spree::StockLocation.count).to eq(0)
    expect(page).to be_axe_clean
  end
end
