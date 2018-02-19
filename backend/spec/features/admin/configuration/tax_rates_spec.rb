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
    click_button "Create"
    expect(page).to have_content("Tax Rate has been successfully created!")
  end
end
