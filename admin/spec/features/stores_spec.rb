# frozen_string_literal: true

require 'spec_helper'

describe "Stores", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists stores and allows deleting them" do
    create(:store, name: "B2C Store")
    create(:store, name: "B2B Store")

    visit "/admin/stores"
    expect(page).to have_content("B2C Store")
    expect(page).to have_content("B2B Store")
    expect(page).to be_axe_clean

    select_row("B2C Store")
    click_on "Delete"
    expect(page).to have_content("Stores were successfully removed.")
    expect(page).not_to have_content("B2C Store")
    expect(Spree::Store.count).to eq(1)
    expect(page).to be_axe_clean
  end
end
