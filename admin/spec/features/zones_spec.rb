# frozen_string_literal: true

require "spec_helper"

describe "Zones", :js, type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }
  let(:canada) { create(:country, iso: "CA") }
  let(:france) { create(:country, iso: "FR") }
  let(:usa) { create(:country) }

  let(:states) do
    [
      create(:state, name: "Alberta", country: canada),
      create(:state, name: "Manitoba", country: canada)
    ]
  end

  it "lists zones and allows deleting them" do
    create(:zone, name: "Europe", countries: [france])
    create(:zone, name: "North America", countries: [usa, canada])

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

  context "creating new zone" do
    before { states }

    it "creates a new zone" do
      visit "/admin/zones"
      click_on "Add new"

      fill_in "Name", with: "Canada"
      solidus_select ["Alberta (Canada)", "Manitoba (Canada)"], from: "States"
      fill_in "Description", with: "some Canada provinces"
      click_on "Add Zone"

      expect(page).to have_content("Zone was successfully created.")
      expect(page).to have_content("Alberta and Manitoba")
      expect(page).to have_content("some Canada provinces")
    end

    it "shows validation errors" do
      visit "/admin/zones"
      click_on "Add new"

      fill_in "Name", with: ""
      click_on "Add Zone"

      expect(page).to have_content("can't be blank")
    end
  end

  context "editing an existing zone" do
    before do
      create(:zone, name: "CA", states:)
      create(:country, iso: "US")
    end

    it "updates the zone" do
      visit "/admin/zones"
      click_on "CA"

      fill_in "Name", with: "US"
      fill_in "Description", with: "United States"
      solidus_select "Country based", from: "Kind"
      solidus_select "United States", from: "Countries"
      click_on "Update Zone"

      expect(page).to have_content("Zone was successfully updated.")
      expect(page).to have_content("US")
      expect(page).to have_content("United States")
      expect(page).to have_content("country")
    end

    it "shows validation errors" do
      visit "/admin/zones"
      click_on "CA"
      expect(page).to have_field("Name", with: "CA")
      fill_in "Name", with: ""
      click_on "Update Zone"

      expect(page).to have_content("can't be blank")
    end
  end
end
