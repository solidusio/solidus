# frozen_string_literal: true

require 'spec_helper'

describe "Tax rates", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists tax rates and allows deleting them" do
    create(:tax_rate, name: "Clothing")
    create(:tax_rate, name: "Food")

    visit "/admin/tax_rates"
    expect(page).to have_content("Clothing")
    expect(page).to have_content("Food")
    expect(page).to be_axe_clean

    select_row("Clothing")
    click_on "Delete"
    expect(page).to have_content("Tax rates were successfully removed.")
    expect(page).not_to have_content("Clothing")
    expect(Spree::TaxRate.count).to eq(1)
    expect(page).to be_axe_clean
  end

  context "creating new tax rate" do
    before do
      create(:zone, name: "EU")
      create(:tax_category, name: "Default")
      create(:tax_category, name: "Specific")
    end

    it "creates new tax rate" do
      visit "/admin/tax_rates"
      click_on "Add new"
      expect(page).to have_current_path("/admin/tax_rates/new")
      expect(page).to be_axe_clean

      fill_in "Name", with: "Clothing"
      solidus_select "EU", from: "Zone"
      solidus_select %w[Default Specific], from: "Tax Categories"
      switch "Show Rate in Label"
      solidus_select "Default Tax", from: "Calculator"
      fill_in "Rate", with: "0.18"
      solidus_select "Item level", from: "Tax Rate Level"
      switch "Included in Price"
      fill_in "Start Date", with: 1.month.ago
      fill_in "Expiration Date", with: 1.year.from_now
      within("header") { click_on "Save" }

      expect(page).to have_current_path("/admin/tax_rates")
      expect(page).to have_content("Tax rate was successfully created.")
      expect(page).to have_content("EU")
      expect(page).to have_content("Clothing")
      expect(page).to have_content("Default, Specific")
      expect(page).to have_content("18.0%")
      expect(page).to have_content(1.year.from_now.to_date.to_s)
      expect(page).to have_content("Default Tax")
    end

    context "with invalid attributes" do
      it "shows validation errors" do
        visit "/admin/tax_rates"
        click_on "Add new"

        within("header") { click_on "Save" }

        expect(page).to have_current_path("/admin/tax_rates/new")
        expect(page).to have_content("can't be blank")
        expect(page).to have_content("is not a number")
      end
    end
  end
end
