# frozen_string_literal: true

require 'spec_helper'

describe "Properties", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists properties and allows deleting them" do
    create(:property, name: "Type", presentation: "Type")
    create(:property, name: "Size", presentation: "Size")

    visit "/admin/properties"
    expect(page).to have_content("Type")
    expect(page).to have_content("Size")

    expect(page).to be_axe_clean

    select_row("Type")
    click_on "Delete"
    expect(page).to have_content("Properties were successfully removed.")
    expect(page).not_to have_content("Type")
    expect(Spree::Property.count).to eq(1)
  end
end
