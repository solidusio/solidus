# frozen_string_literal: true

require 'spec_helper'

describe "Shipping Methods", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists tax categories and allows deleting them" do
    create(:shipping_method, name: "FAAAST")

    visit "/admin/shipping_methods"
    expect(page).to have_content("FAAAST")
    expect(page).to be_axe_clean

    select_row("FAAAST")
    click_on "Delete"
    expect(page).to have_content("Shipping methods were successfully removed.")
    expect(page).not_to have_content("FAAAST")
    expect(Spree::ShippingMethod.count).to eq(0)
    expect(page).to be_axe_clean
  end
end
