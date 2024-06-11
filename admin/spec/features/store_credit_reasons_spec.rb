# frozen_string_literal: true

require 'spec_helper'

describe "Store Credit Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists Store Credit Reasons and allows deleting them" do
    create(:store_credit_reason, name: "Default-store-credit-reason")

    visit "/admin/store_credit_reasons"
    expect(page).to have_content("Default-store-credit-reason")
    expect(page).to be_axe_clean

    select_row("Default-store-credit-reason")
    click_on "Delete"
    expect(page).to have_content("Store Credit Reasons were successfully removed.")
    expect(page).not_to have_content("Default-store-credit-reason")
    expect(Spree::StoreCreditReason.count).to eq(0)
    expect(page).to be_axe_clean
  end
end
