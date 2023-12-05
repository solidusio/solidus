# frozen_string_literal: true

require 'spec_helper'

describe "Zones", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists zones and allows deleting them" do
    create(:zone, name: "Europe")
    create(:zone, name: "North America")

    visit "/admin/zones"
    expect(page).to have_content("Europe")
    expect(page).to have_content("North America")
    expect(page).to be_axe_clean

    select_row("Europe")
    click_on "Delete"
    expect(page).to have_content("Zones were successfully removed.")
    expect(page).not_to have_content("Europe")
    expect(Spree::Zone.count).to eq(1)
    expect(page).to be_axe_clean
  end
end
