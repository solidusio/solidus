# frozen_string_literal: true

require 'spec_helper'

describe "Payment Methods", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists users and allows deleting them" do
    create(:check_payment_method, name: "Check", active: true)
    create(:simple_credit_card_payment_method, name: "Credit Card", active: false)
    create(:store_credit_payment_method, name: "Store Credit Users", available_to_users: true)
    create(:store_credit_payment_method, name: "Store Credit Admins", available_to_admin: true)

    visit "/admin/payment_methods"
    expect(page).to have_content("Check")
    expect(page).not_to have_content("Credit Card")
    expect(page).to have_content("Store Credit Users")
    expect(page).to have_content("Store Credit Admins")
    click_on "Inactive"
    expect(page).not_to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).not_to have_content("Store Credit Users")
    expect(page).not_to have_content("Store Credit Admins")
    click_on "Admin"
    expect(page).to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).to have_content("Store Credit Admins")
    expect(page).not_to have_content("Store Credit Users")
    click_on "Storefront"
    expect(page).to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).not_to have_content("Store Credit Admins")
    expect(page).to have_content("Store Credit Users")
    click_on "All"
    expect(page).to have_content("Check")
    expect(page).to have_content("Credit Card")
    expect(page).to have_content("Store Credit Admins")
    expect(page).to have_content("Store Credit Users")

    expect(page).to be_axe_clean

    select_row("Check")
    click_on "Delete"
    expect(page).to have_content("Payment Methods were successfully removed.")
    expect(page).not_to have_content("Check")
    expect(Spree::PaymentMethod.count).to eq(3)
  end
end
