# frozen_string_literal: true

require 'spec_helper'
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

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

  include_examples 'feature: bulk delete resources' do
    let(:resource_factory) { :stock_location }
    let(:index_path) { "/admin/stock_locations" }
  end
end
