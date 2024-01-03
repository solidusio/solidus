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
end
