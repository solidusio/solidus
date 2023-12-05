# frozen_string_literal: true

require 'spec_helper'

describe "Shipping Categories", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists shipping categories and allows deleting them" do
    create(:shipping_category, name: "Default-shipping")

    visit "/admin/shipping_categories"
    expect(page).to have_content("Default-shipping")
    expect(page).to be_axe_clean

    select_row("Default-shipping")
    click_on "Delete"
    expect(page).to have_content("Shipping categories were successfully removed.")
    expect(page).not_to have_content("Default-shipping")
    expect(Spree::ShippingCategory.count).to eq(0)
    expect(page).to be_axe_clean
  end
end
