# frozen_string_literal: true

require "spec_helper"

describe "Shipping Methods", type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists shipping methods and allows deleting them", :js do
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

  it "shows the link for creating a new shipping method" do
    visit "/admin/shipping_methods"

    expect(page).to have_content("Add new")
    expect(page).to have_selector(:css, 'a[href="/admin/shipping_methods/new"]')
  end
end
