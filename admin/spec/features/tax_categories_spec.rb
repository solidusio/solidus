# frozen_string_literal: true

require 'spec_helper'

describe "Tax categories", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists tax categories and allows deleting them" do
    create(:tax_category, name: "Clothing")
    create(:tax_category, name: "Food")

    visit "/admin/tax_categories"
    expect(page).to have_content("Clothing")
    expect(page).to have_content("Food")
    expect(page).to be_axe_clean

    select_row("Clothing")
    click_on "Delete"
    expect(page).to have_content("Tax categories were successfully removed.")
    expect(page).not_to have_content("Clothing")
    expect(Spree::TaxCategory.count).to eq(1)
    expect(page).to be_axe_clean
  end
end
