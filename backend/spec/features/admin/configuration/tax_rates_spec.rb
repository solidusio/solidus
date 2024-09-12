# frozen_string_literal: true

require 'spec_helper'

describe "Tax Rates", type: :feature do
  stub_authorization!

  let!(:tax_rate) { create(:tax_rate, calculator: stub_model(Spree::Calculator)) }

  before do
    visit spree.admin_path
    click_link "Taxes"
  end

  # Regression test for https://github.com/spree/spree/issues/535
  it "can see a tax rate in the list if the tax category has been deleted" do
    tax_rate.tax_categories.first.update_column(:deleted_at, Time.current)
    click_link "Tax Rates"

    expect(find("table tbody td:nth-child(3)")).to have_content('N/A')
  end

  # Regression test for https://github.com/spree/spree/issues/1422
  it "can create a new tax rate" do
    click_link "Tax Rates"
    click_link "New Tax Rate"
    fill_in "Rate", with: "0.05"
    fill_in "Expiration Date", with: "2050-01-01"
    click_button "Create"
    expect(page).to have_content("Tax Rate has been successfully created!")
  end

  describe "listing" do
    let(:calculator) { create(:default_tax_calculator) }
    let!(:tax_rate_1) { create(:tax_rate, name: "Tax Rate 1", calculator:) }
    let!(:tax_rate_2) { create(:tax_rate, name: "Tax Rate 2", calculator:) }

    it "shows all tax rates if no filter is applied" do
      visit spree.admin_tax_rates_path
      within "table" do
        expect(page).to have_content tax_rate_1.name
        expect(page).to have_content tax_rate_2.name
      end
    end

    it "it is possible to filter by zone" do
      visit spree.admin_tax_rates_path
      select tax_rate_1.zone.name, from: "Zone"
      click_on "Filter Results"
      within "table" do
        expect(page).to have_content tax_rate_1.name
        expect(page).to_not have_content tax_rate_2.name
      end
    end

    it "it is possible to filter by tax category" do
      visit spree.admin_tax_rates_path
      select tax_rate_2.tax_categories.first.name, from: "Tax Category"
      click_on "Filter Results"
      within "table" do
        expect(page).to have_content tax_rate_2.name
        expect(page).to_not have_content tax_rate_1.name
      end
    end

    it "it displays the translated calculator name" do
      visit spree.admin_tax_rates_path
      within "table" do
        expect(page).to have_content calculator.class.model_name.human
      end
    end
  end
end
